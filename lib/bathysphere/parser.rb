require 'yaml'

module Bathysphere
  class Parser

    attr_reader :file, :refinements_store
    private :file, :refinements_store

    def initialize(file_path)
      @file = file_path.downcase
      @data = YAML.load_file(file)
    end

    # Set a refinements store
    #
    # When a refinements store is available, the #fetch
    # method will attempt to retrieve the refinements by
    # calling reader methods on the store instead of using
    # additional refinement arguments.
    #
    # Returns self (i.e. is a chainable method).
    def using(refinements_store)
      @refinements_store = refinements_store
      self
    end

    def fetch(option_name, *refinements)

      option_value = @data.fetch(option_name.to_s) do
        raise KeyError, "key not found #{option_name.to_s.inspect} in #{file}"
      end

      if option_value.kind_of?(Hash)
        fetch_recursively(option_value, *refinements)
      else
        option_value
      end
    end

    private

      def fetch_recursively(option_value, *refinements)
        keys(option_value).inject(values(option_value)) { |data, key|
          refinement = refinements.shift.to_s
          data.fetch(refinement) do
            refinement = refinements_store.send(key).to_s
            data.fetch(refinement) do
              raise KeyError, "refinement not found #{refinement.inspect} in #{file}"
            end
          end
        }
      end

      def keys(option_value)

        option_value.fetch('key', '').split(',')
      end

      def values(option_value)
        option_value.fetch('values') do
          raise KeyError, "key not found \"values\" in #{file}"
        end
      end
  end
end
