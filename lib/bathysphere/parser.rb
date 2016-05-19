require 'yaml'

module Bathysphere
  class Parser

    attr_reader :file
    private :file

    def initialize(file_path)
      @file = file_path.downcase
      @data = YAML.load_file(file)
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
            raise KeyError, "key not found #{refinement.inspect} in #{file}"
          end
        }
      end

      def keys(option_value)
        option_value.fetch('key', '').split(',')
      end

      def values(option_value)
        option_value.fetch('values', '')
      end
  end
end
