require 'shell_wrapper'

describe ShellWrapper do

	before (:each) do
		@shell = ShellWrapper.new
  end

	it "should omit . and .. from dir list" do
		Dir.should_receive(:new).and_return ['.', '..', 'bar', 'bar2']
		@shell.real_dir_entries('foo').should == ['bar', 'bar2']
	end

	it "should omit . and .. when retrieving the newest file in a directory" do
		Dir.should_receive(:new).and_return ['.', '..', 'bar', 'bar2']
		File.should_receive(:mtime).with('foo/bar').and_return 2
		File.should_receive(:mtime).with('foo/bar2').and_return 1
		@shell.newest_dir_entry('foo').should == "bar"
	end

end
