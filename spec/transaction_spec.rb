require 'spec_helper'

describe Transaction do
  before(:each) do
    @good_transaction = "APPLE	US	000000001	 	 	Acme Corp	Widgets	 	1	2	1.4	01/21/2010	01/21/2010	CAD	CA	CAD	 	 	 	350525324	1.99	 	 	 	 	 	 ".split(/\t/)
    @free_transaction = "APPLE	US	000000000	 	 	Acme Corp	Sprockets	 	1	13	0	01/21/2010	01/21/2010	USD	HK	USD	 	 	 	350523538	0	 	 	 	 	 	 ".split(/\t/)
    # not enough tabs
    @malformed_transaction = "APPLE	US	000000001	 	 	Acme Corp	Widgets	 	1	1	0	1/21/10	1/21/10	USD	US	USD".split(/\t/)
    # price tier does not match
    @badly_priced_transaction = "APPLE	US	000000001	 	 	Acme Corp	Widgets	 	1	2	1.2	01/21/2010	01/21/2010	CAD	CA	CAD	 	 	 	350525324	1.19	 	 	 	 	 	 ".split(/\t/)
  end

  it "should load good transactions" do
    xion = Transaction.new @good_transaction
    xion.price_tier.should == 2

    xion = Transaction.new @free_transaction
    xion.price_tier.should == 0
  end

  it "should raise error on malformed transaction" do
    lambda { Transaction.new @malformed_transaction }.should raise_error(WrongNumberOfElements)
  end

  it "should raise error on badly priced transaction" do
    lambda { Transaction.new @badly_priced_transaction }.should raise_error(PriceTierNotFound)
  end
end