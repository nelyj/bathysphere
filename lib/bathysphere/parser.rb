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
        fetch_recursively(option_name, *refinements)
      else
        option_value
      end
    end

    private

      def fetch_recursively(option_name, *refinements)
        keys(option_name).inject(raw_values(option_name)) { |data, key|
          data.fetch(refinements.shift.to_s) do
            raise KeyError, "key not found #{option_name.to_s.inspect} in #{file}"
          end
        }
      end

      def keys(option_name)
        raw_key(option_name).split(',')
      end

      def raw_values(option_name)
        @data.fetch(option_name.to_s) {
          raise KeyError, "key not found #{option_name.to_s.inspect} in #{file}"
        }.fetch('values', '')
      end

      def raw_key(option_name)
        @data.fetch(option_name.to_s) {
          raise KeyError, "key not found #{option_name.to_s.inspect} in #{file}"
        }.fetch('key', '')
      end
  end
end
