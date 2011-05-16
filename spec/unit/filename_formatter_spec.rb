require 'filename_formatter'

describe FilenameFormatter do

	before (:each) do
		@formatter = FilenameFormatter.new
  end

  it 'should extract the last element of a dir path' do
		@formatter.extract_last_path_item("").should == ""
		@formatter.extract_last_path_item("/").should == ""
		@formatter.extract_last_path_item("a").should == "a"
		@formatter.extract_last_path_item("a/b/").should == "b"
		@formatter.extract_last_path_item("/a/b/c").should == "c"
  end

	it 'should remove the filename extension' do
		@formatter.without_extension("").should == ""
		@formatter.without_extension("a").should == "a"		
		@formatter.without_extension("a.b").should == "a"
		@formatter.without_extension("a.b.c").should == "a.b"
	end

	it 'should extract the step number from the state dir name' do
		@formatter.step_number_from_state_dir('state_0').should == 0
		@formatter.step_number_from_state_dir('state_1').should == 1
		@formatter.step_number_from_state_dir('state_01').should == 1
		@formatter.step_number_from_state_dir('state_123').should == 123
	end
end
