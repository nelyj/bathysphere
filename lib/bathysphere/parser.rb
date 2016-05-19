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

      begin
        option_data = @data.fetch(option_name.to_s)
      rescue KeyError
        raise KeyError, "key not found #{option_name.to_s.inspect} in #{file}"
      end

      if @data.fetch(option_name.to_s).kind_of?(Hash)
        keys(option_name).inject(raw_values(option_name)){ |data, key|
          begin
            data.fetch(refinements.shift.to_s)
          rescue KeyError
            raise KeyError, "key not found #{option_name.to_s.inspect} in #{file}"
          end
        }
      else
        @data.fetch(option_name.to_s)
      end
    end

    private

      def keys(option_name)
        raw_key(option_name).split(',')
      end

      def raw_values(option_name)
        @data.fetch(option_name.to_s).fetch('values', '')
      rescue KeyError
        raise KeyError, "key not found #{option_name.to_s.inspect} in #{file}"
      end

      def raw_key(option_name)
        @data.fetch(option_name.to_s).fetch('key', '')
      rescue KeyError
        raise KeyError, "key not found #{option_name.to_s.inspect} in #{file}"
      end
  end
end
