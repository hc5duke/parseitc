require 'lib/parseitc/transaction'

module ParseITC
  class Parser
    attr_accessor :transactions
    Version = '0.1.3'
    # files can be either string or array
    def initialize(files=[])
      @transactions = []
      add_files files
    end

    def add_files files
      [files].flatten.each do |file|
        add_file file
      end
    end

    def add_file file
      lines = File.readlines(file)
      lines.shift if lines.first.match(/^Provider/)
      lines.each do |xion|
        add_transaction xion
      end
    end

    def add_transaction transaction
      @transactions << Transaction.new(transaction.split(/\t|\n/))
    end

    private
      def method_missing(method_id, *arguments)
        match = /numbers_by_([_a-zA-Z]\w*)/.match(method_id.to_s)
        if match
          numbers_by(match)
        else
          super
        end
      end

      def get_count_by_field field
        values = {}
        @transactions.each do |xion|
          value = xion.send(field.to_sym)
          values[value] = (values[value] || 0) + xion.units.to_i
        end
        values
      end

      def numbers_by(match)
        field = match.captures.first
        raise NoMethodError.new("#{match}") unless @transactions.first.has_field? field
        get_count_by_field field
      end
    # end private
  end

  # deprecated
  class TransactionParser < Parser
  end
end