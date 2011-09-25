require 'record/text_converter'

describe TextConverter do

  before (:each) do
		@escape_sequence_start = 0x1b.chr
		@escape_sequence_end = 0x6d.chr
    @text_converter = TextConverter.new
  end

	it "should leave nil as nil" do
		@text_converter.remove_escape_sequences(nil).should be_nil
		
	end
	
  it "should leave text without escape sequences untouched" do
		@text_converter.remove_escape_sequences("text without escape sequence").should == "text without escape sequence"
  end

  it "should remove escape sequences from text" do
		@text_converter.remove_escape_sequences("#{@escape_sequence_start}ab#{@escape_sequence_end}").should == ""
		@text_converter.remove_escape_sequences("a#{@escape_sequence_start}b#{@escape_sequence_end}c").should == "ac"
		@text_converter.remove_escape_sequences("ab#{@escape_sequence_start}#{@escape_sequence_end}cd").should == "abcd"
  end

	it "should remove escape sequences non greedy" do
		@text_converter.remove_escape_sequences("#{@escape_sequence_start}a#{@escape_sequence_end}b#{@escape_sequence_start}c#{@escape_sequence_end}").should == "b"
	end
	
end