require 'spec_helper'

describe TransactionParser, "when created" do
  before(:each) do
    #
  end

  it "should be able to open file or files" do
    lambda{ TransactionParser.new([FIXTURES_DIR + '/uploads/demo1.txt']) }.should_not raise_error
  end

  it "should return error when file does not exist" do
    lambda{ TransactionParser.new(['!']) }.should raise_error(Errno::ENOENT)
  end

  it "should return error when file is badly formed" do
    lambda{ TransactionParser.new([FIXTURES_DIR + '/uploads/bad_demo1.txt']) }.should raise_error(WrongNumberOfElements)
  end
end
