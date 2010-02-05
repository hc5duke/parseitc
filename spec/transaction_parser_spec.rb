require 'spec_helper'

describe TransactionParser do
  before(:each) do
    @good_files = [FIXTURES_DIR + '/uploads/demo1.txt',
      FIXTURES_DIR + '/uploads/demo2.txt']
    @bad_file = FIXTURES_DIR + '/uploads/bad_demo1.txt'
    @no_file = '!'

    @count_good_files = [53, 55]
  end

  describe "when created" do
    it "should handle empty array of files" do
      lambda{ @report = TransactionParser.new([])             }.should_not raise_error
      @report.transactions.count.should == 0
    end

    it "should be able to open file" do
      lambda{ @report = TransactionParser.new(@good_files[0]) }.should_not raise_error
      @report.transactions.count.should == @count_good_files[0]
    end

    it "should be able to open multiple files" do
      lambda{ @report = TransactionParser.new(@good_files)    }.should_not raise_error
      @report.transactions.count.should == @count_good_files[0] + @count_good_files[1]
    end

    it "should return error when file does not exist" do
      lambda{ TransactionParser.new(@no_file)       }.should raise_error(Errno::ENOENT)
    end

    it "should return error when file is badly formed" do
      lambda{ TransactionParser.new(@bad_file)      }.should raise_error(WrongNumberOfElements)
    end
  end

  describe "when adding files" do
    before(:each) do
      @report = TransactionParser.new
    end

    it "should be able to add single file" do
      lambda{ @report.add_file(@good_files[0])      }.should_not raise_error
      @report.transactions.count.should == @count_good_files[0]
    end

    it "should be able to add multiple files" do
      lambda{ @report.add_files(@good_files)        }.should_not raise_error
      @report.transactions.count.should == @count_good_files[0] + @count_good_files[1]
    end
  end
end