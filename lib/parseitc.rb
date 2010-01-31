#!/usr/bin/env ruby
module ParseITC
  class TrasactionParser
    Version = '0.1'
    def initialize(filename=nil)
      @transactions = []
      add_file filename if filename
    end

    def add_file filename
      File.readlines(filename)[1..-1].each do |t|
        add_transaction t
      end
    end

    def add_transaction transaction
      values = transaction.split(/\t|\n/)
      raise WrongNumberOfElementsException.new(27, values.length) unless values.length == 27
      @transactions << Transaction.new(values)
    end

    private
      def method_missing(method_id, *arguments)
        if match = /numbers_by_([_a-zA-Z]\w*)/.match(method_id.to_s)
          numbers_by(match)
        else
          super
        end
      end

      def numbers_by(match)
        # puts match.captures.first == "country"
        field = match.captures.first
        values = {}
        @transactions.map do |t|
          value = t.send(field.to_sym)
          values[value] ||= 0
          values[value] += t.units.to_i
        end
        values
      end
    # end private
  end

  class Transaction
    # ignoring some columns that are ignored by iphone apps
    attr_accessor :provider,          # Apple (always)
                  :provider_country,  # US (always?)
                  :company,           # company x
                  :product,           # widgets and sprockets
                  :vendor_identifier, # id you give the product
                  :begin_date,
                  :end_date, 
                  :units,
                  :price,
                  :royalty_currency,
                  :customer_price,
                  :customer_currency,
                  :country,
                  :apple_identifier   # itunes link id
    def initialize array
      @provider           = array[0]
      @provider_country   = array[1]
      @company            = array[5]
      @product            = array[6]
      @vendor_identifier  = array[2]
      @begin_date         = array[11]
      @end_date           = array[12]
      @units              = array[9]
      @price              = array[10]
      @royalty_currency   = array[15]
      @customer_price     = array[20]
      @customer_currency  = array[13]
      @country            = array[14]
      @apple_identifier   = array[19]
    end
  end

  class WrongNumberOfElementsException < Exception
    def initialize(expected, actual)
      super "Invalid number of elements (#{actual}). Expected #{expected} values"
    end
  end
end