#!/usr/bin/env ruby
module ParseITC
  class TransactionParser
    attr_accessor :transactions
    Version = '0.1.2'
    # files can be either string or array
    def initialize(files=[])
      @transactions = []
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

  class Transaction
    YEAR_TWO_THOUSAND = Date.parse("1/1/2000")
    TWO_THOUSAND_YEARS = YEAR_TWO_THOUSAND - Date.parse("1/1/0")

    # ignoring some columns that are ignored by iphone apps
    attr_accessor :provider,          # Apple (always)
                  :provider_country,  # US (always?)
                  :company,           # company x
                  :product,           # widgets and sprockets
                  :vendor_identifier, # id you give the product
                  :date,              # just take the begin date
                  :units,
                  :royalty_price,     # this is what you get paid
                  :royalty_currency,
                  :customer_price,
                  :customer_currency,
                  :vendor_offer_code,
                  :promo_code,
                  :country,
                  :apple_identifier   # itunes link id

    alias :price :royalty_price

    def initialize array
      raise WrongNumberOfElements.new(27, array.length) unless array.length == 27
      @provider           = array[0]
      @provider_country   = array[1]
      @company            = array[5]
      @product            = array[6]
      @vendor_identifier  = array[2]
      @date               = Date.parse(array[11])
      @units              = array[9]
      @royalty_price      = array[10]
      @royalty_currency   = array[15]
      @customer_price     = array[20]
      @customer_currency  = array[13]
      @vendor_offer_code  = array[23]
      @promo_code         = array[25]
      @country            = array[14]
      @apple_identifier   = array[19]

      # Adjust date if necessary ("1/5/10" should not be 10 A.D.)
      @date += TWO_THOUSAND_YEARS if @date < YEAR_TWO_THOUSAND
    end

    def price_tier
      prices = ApplePricing[@royalty_currency.downcase.to_sym]
      prices.find_index(@royalty_price.to_f)
    end

    def has_field? field
      (instance_variables.map{|variable| variable[1..-1]} + public_methods).include? field
    end
  end

  class WrongNumberOfElements < Exception
    def initialize(expected, actual)
      super "Invalid number of elements (#{actual}). Expected #{expected} values"
    end
  end

  # pricing tier info
  ApplePricing = {
    :usd => [0, 0.7, 1.4, 2.1, 2.8, 3.5, 4.2, 4.9, 5.6, 6.3, 7, 7.7, 8.4, 9.1, 9.8, 10.5, 11.2, 11.9, 12.6, 13.3, 14, 14.7, 15.4, 16.1, 16.8, 17.5, 18.2, 18.9, 19.6, 20.3, 21, 21.7, 22.4, 23.1, 23.8, 24.5, 25.2, 25.9, 26.6, 27.3, 28, 28.7, 29.4, 30.1, 30.8, 31.5, 32.2, 32.9, 33.6, 34.3, 35, 38.5, 42, 45.5, 49, 52.5, 56, 59.5, 63, 66.5, 70, 77, 84, 91, 98, 105, 112, 119, 126, 133, 140, 147, 154, 161, 168, 175, 210, 245, 280, 315, 350, 420, 490, 560, 630, 700],
    :cad => [0, 0.7, 1.4, 2.1, 2.8, 3.5, 4.2, 4.9, 5.6, 6.3, 7, 7.7, 8.4, 9.1, 9.8, 10.5, 11.2, 11.9, 12.6, 13.3, 14, 14.7, 15.4, 16.1, 16.8, 17.5, 18.2, 18.9, 19.6, 20.3, 21, 21.7, 22.4, 23.1, 23.8, 24.5, 25.2, 25.9, 26.6, 27.3, 28, 28.7, 29.4, 30.1, 30.8, 31.5, 32.2, 32.9, 33.6, 34.3, 35, 38.5, 42, 45.5, 49, 52.5, 56, 59.5, 63, 66.5, 70, 77, 84, 91, 98, 105, 112, 119, 126, 133, 140, 147, 154, 161, 168, 175, 210, 245, 280, 315, 350, 420, 490, 560, 630, 700],
    :aud => [0, 0.76, 1.58, 2.54, 3.18, 3.81, 5.08, 5.72, 6.36, 7.63, 8.27, 8.9, 9.54, 10.18, 10.81, 11.45, 12.08, 12.72, 13.99, 14.63, 15.27, 15.9, 17.18, 17.81, 18.45, 19.08, 20.36, 20.99, 21.63, 22.27, 23.54, 24.18, 24.81, 25.45, 26.72, 27.36, 27.99, 28.63, 29.27, 29.9, 30.54, 31.18, 31.81, 33.08, 33.72, 34.36, 34.99, 36.27, 36.9, 37.54, 38.18, 44.54, 47.72, 50.9, 57.27, 60.45, 63.63, 66.81, 69.99, 73.18, 76.36, 89.08, 95.45, 101.81, 108.18, 120.9, 127.27, 139.99, 146.36, 152.72, 159.08, 165.45, 171.81, 178.18, 184.54, 190.9, 222.72, 254.54, 286.36, 318.18, 381.81, 445.45, 509.08, 572.72, 636.36, 763.63],
    :jpy => [0, 81, 161, 245, 315, 420, 490, 560, 630, 700, 840, 910, 980, 1050, 1120, 1190, 1260, 1400, 1470, 1540, 1610, 1680, 1750, 1820, 1960, 2030, 2100, 2170, 2240, 2310, 2450, 2520, 2590, 2660, 2730, 2800, 2870, 3010, 3080, 3150, 3220, 3290, 3360, 3430, 3500, 3640, 3710, 3780, 3850, 3920, 4060, 4200, 4900, 5250, 5600, 5950, 6300, 7000, 7350, 7700, 8050, 9100, 9800, 10500, 11200, 12600, 13300, 14000, 14700, 15400, 16100, 16800, 17500, 18200, 18900, 20300, 24500, 28000, 31500, 35000, 40600, 49000, 56000, 63000, 70000, 80500],
    :eur => [0, 0.48, 0.97, 1.45, 1.82, 2.43, 3.04, 3.34, 3.65, 4.25, 4.86, 5.47, 6.08, 6.39, 6.69, 7.3, 7.91, 8.52, 8.82, 9.12, 9.73, 10.34, 10.95, 11.25, 11.56, 12.17, 12.78, 13.08, 13.39, 13.99, 14.6, 15.21, 15.52, 15.82, 16.43, 17.04, 17.65, 17.95, 18.25, 18.86, 19.47, 20.08, 20.39, 20.69, 21.3, 21.91, 22.52, 22.82, 23.12, 23.73, 24.34, 26.17, 27.39, 30.43, 33.47, 36.52, 38.34, 39.56, 42.6, 45.65, 48.69, 51.73, 54.78, 57.82, 60.86, 66.95, 73.04, 76.08, 79.12, 85.21, 91.3, 97.39, 103.47, 109.56, 115.65, 121.73, 146.08, 170.43, 194.78, 219.12, 243.47, 292.17, 340.86, 389.56, 438.25, 486.95],
    :gbp => [0, 0.36, 0.72, 1.09, 1.45, 1.82, 2.12, 2.43, 3.04, 3.34, 3.65, 3.95, 4.25, 4.56, 4.86, 5.47, 5.78, 6.08, 6.69, 6.99, 7.3, 7.6, 7.91, 8.52, 8.82, 9.12, 9.43, 9.73, 10.34, 10.65, 10.95, 11.25, 11.56, 12.17, 12.47, 12.78, 13.08, 13.39, 13.99, 14.3, 14.6, 14.91, 15.21, 15.82, 16.12, 16.43, 16.73, 17.04, 17.65, 17.95, 18.25, 20.08, 21.3, 23.12, 24.34, 26.17, 27.39, 30.43, 32.25, 33.47, 36.52, 39.56, 42.6, 45.65, 48.69, 51.73, 54.78, 57.82, 60.86, 66.95, 69.99, 73.04, 76.08, 79.12, 85.21, 91.3, 109.56, 121.73, 146.08, 170.43, 182.6, 213.04, 243.47, 273.91, 304.34, 365.21]
  }
end
