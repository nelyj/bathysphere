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
      'Display name!'

      keys(option_name).inject(raw_values(option_name)){ |data, key|
        begin
          data.fetch(refinements.shift.to_s)
        rescue
          raise KeyError, "key not found #{option_name.inspect} in #{file}"
        end
      }
    end

    private

      def keys(option_name)
        raw_key(option_name).split(',')
      end

      def raw_values(option_name)
        @data.fetch(option_name.to_s).fetch('values', '')
      rescue
        raise KeyError, "key not found #{option_name.inspect} in #{file}"
      end

      def raw_key(option_name)
        @data.fetch(option_name.to_s).fetch('key', '')
      rescue
        raise KeyError, "key not found #{option_name.inspect} in #{file}"
      end
  end
end
