module ParseITC
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

    alias :price :customer_price

    def initialize array
      raise WrongNumberOfElements.new(27, array.length) unless array.length == 27
      @provider           = array[0]
      @provider_country   = array[1]
      @company            = array[5]
      @product            = array[6]
      @vendor_identifier  = array[2]
      @date               = Date.parse(array[11])
      @product_type_id    = array[8] # 1 = new, 7 = update
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
      raise PriceTierNotFound.new(royalty_price, royalty_currency) unless price_tier
    end

    def price_tier
      @price_tier ||= begin
        prices = ApplePricing[@royalty_currency.downcase.to_sym]
        if @customer_price.to_f == 0
          0
        else
          prices.find_index(@royalty_price.to_f)
        end
      rescue
        nil
      end
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

  class PriceTierNotFound < Exception
    def initialize(amount, currency)
      super "No price tier found for #{amount} #{currency}"
    end
  end
end