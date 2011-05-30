require 'shell_wrapper'

describe ShellWrapper do

	before (:each) do
		@shell = ShellWrapper.new
  end

	it "should return the files in a directory" do
		Dir.should_receive(:new).with('myDir').and_return ['file1', 'dir', 'file2']
		File.should_receive(:file?).with('file1').and_return true
		File.should_receive(:file?).with('dir').and_return false
		File.should_receive(:file?).with('file2').and_return true
		@shell.files_in_dir('myDir').should == ['file1', 'file2']
	end
	
	it "should filter files by regex pattern" do
		Dir.should_receive(:new).with('myDir').and_return ['file1.rb', 'file2.py']
		File.should_receive(:file?).any_number_of_times.and_return true
		@shell.files_in_dir('myDir', '.*\.rb').should == ['file1.rb']
	end
	
	it "should filter files by regex pattern recursivly" do
		Dir.should_receive(:glob).with('**/*').and_return ['file1.rb', 'file2.py']
		File.should_receive(:file?).any_number_of_times.and_return true
		@shell.files_in_dir_tree('myDir', '.*\.rb').should == ['file1.rb']
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
	
	it "should retrieve the newest dir from a file list" do
		File.should_receive(:mtime).with('foo/bar/file1').and_return 2
		File.should_receive(:mtime).with('foo/file2').and_return 1
		@shell.newest_dir_entry('foo', ['bar/file1', 'file2']).should == 'bar/file1'
	end
	
	it "should prepend *.sh start scripts with 'bash'" do
		@shell.expand_run_command('aCommand.sh').should == 'bash aCommand.sh'
	end
	
	it "should not prepend *.bat start scripts with anything" do
		@shell.expand_run_command('aCommand.bat').should == 'aCommand.bat'
	end
	
	it "should not prepend *.cmd start scripts with anything" do
		@shell.expand_run_command('aCommand.cmd').should == 'aCommand.cmd'
	end
	
	

end
