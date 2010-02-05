require 'spec_helper'

describe Parser do
  before(:each) do
    @good_files = [FIXTURES_DIR + '/uploads/demo1.txt',
      FIXTURES_DIR + '/uploads/demo2.txt']
    @bad_file = FIXTURES_DIR + '/uploads/bad_demo1.txt'
    @no_file = '!'

    @count_good_files = [53, 55]
  end

  describe "when created" do
    it "should handle empty array of files" do
      @parser = Parser.new []
      @parser.transactions.count.should == 0
    end

    it "should be able to open file" do
      @parser = Parser.new @good_files[0]
      @parser.transactions.count.should == @count_good_files[0]
    end

    it "should be able to open multiple files" do
      @parser = Parser.new @good_files
      @parser.transactions.count.should == @count_good_files[0] + @count_good_files[1]
    end

    it "should return error when file does not exist" do
      lambda{ Parser.new(@no_file)  }.should raise_error(Errno::ENOENT)
    end

    it "should return error when file is badly formed" do
      lambda{ Parser.new(@bad_file) }.should raise_error(WrongNumberOfElements)
    end
  end

  describe "when adding files" do
    before(:each) do
      @parser = Parser.new
    end

    it "should be able to add single file" do
      @parser.add_file @good_files[0]
      @parser.transactions.count.should == @count_good_files[0]
    end

    it "should be able to add multiple files" do
      @parser.add_files @good_files
      @parser.transactions.count.should == @count_good_files[0] + @count_good_files[1]
    end
  end

  describe "when adding transaction" do
    before(:each) do
      @parser = Parser.new
      @good_transaction = "APPLE	US	000000001	 	 	Acme Corp	Widgets	 	1	1	0	1/21/10	1/21/10	USD	US	USD	 	 	 	350525324	0	 	 	 	 	CR-RW	 "
      @bad_transaction = "APPLE	US	000000001	 	 	Acme Corp	Widgets	 	1	1	0	1/21/10	1/21/10	USD	US	USD"
    end

    it "should handle correctly formed transaction" do
      @parser.add_transaction @good_transaction
      @parser.transactions.count.should == 1
    end

    it "should handle incorrectly formed transaction" do
      lambda { @parser.add_transaction @bad_transaction }.should raise_error(WrongNumberOfElements)
    end
  end

  describe "when counting transactions" do
    before(:each) do
      @parser = Parser.new @good_files[0]
    end

    it "should handle correctly formed transaction" do
      @parser.transactions.count.should == @count_good_files[0]
    end
  end
end