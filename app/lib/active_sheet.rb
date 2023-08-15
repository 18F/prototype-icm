require 'csv'

class ActiveSheet

  class Base

    class << self

      @sheet = nil

      def sheet=(path)
        @sheet = path
      end

      def sheet
        @sheet
      end

      def column_names
        source.headers
      end

      def find_by(options={})
        find_by!(options)
      rescue RecordNotFound => e
        nil
      end

      def find_by!(options={})
        raise "Must only give 1 option to #find_by" unless options.size == 1
        key, value = options.to_a.first.map(&:to_s)
        raise "Must give a key in the header: #{source.headers} but gave #{key.inspect}" unless source.headers.include?(key)
        maybe_result = source.detect { |row| row[key] == value }
        return maybe_result if maybe_result
        raise RecordNotFound.new(key, value)
      end

      def source
        raise "No sheet given for model #{self.name}" if @sheet.nil?
        @file ||= CSV.read(self.sheet, headers: true)
      end

    end


  end

  def self.use(path)
    Class.new(ActiveSheet::Base) do
      self.sheet = path
    end
  end

  class RecordNotFound < StandardError
    def initialize(key, value)
      @key = key
      @value = value
    end

    def message
      <<~MESSAGE
        I couldn't find a record for #{@key.inspect}: #{@value.inspect}.
      MESSAGE
    end
  end
end
