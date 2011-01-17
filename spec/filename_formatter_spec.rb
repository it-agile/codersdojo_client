require 'filename_formatter'

describe FilenameFormatter do

	before (:each) do
		@formatter = FilenameFormatter.new
  end

  it 'extract the last element of a dir path' do
		@formatter.extract_last_path_item("").should == ""
		@formatter.extract_last_path_item("/").should == ""
		@formatter.extract_last_path_item("a").should == "a"
		@formatter.extract_last_path_item("a/b/").should == "b"
		@formatter.extract_last_path_item("/a/b/c").should == "c"
  end

end
