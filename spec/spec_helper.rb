require 'spec/autorun'
require 'spork'
require 'lib/parseitc'
include ParseITC

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  Spec::Runner.configure do |config|
    #
    # If you declare global fixtures, be aware that they will be declared
    # for all of your examples, even those that don't use them.
    #
    # You can also declare which fixtures to use (for example fixtures for test/fixtures):
    #
    # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
    #
    # == Mock Framework
    #
    # RSpec uses it's own mocking framework by default. If you prefer to
    # use mocha, flexmock or RR, uncomment the appropriate line:
    #
    config.mock_with :mocha

    def valid_address(attributes = {})
      {
        :first_name => 'John',
        :last_name => 'Doe',
        :address1 => '2010 Cherry Ct.',
        :city => 'Mobile',
        :state => 'AL',
        :zip => '36608',
        :country => 'US'
      }.merge(attributes)
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
end

FIXTURES_DIR = "#{File.dirname(__FILE__)}/fixtures"
