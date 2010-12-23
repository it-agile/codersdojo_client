require 'argument_parser'

describe ArgumentParser do
	
	before (:each) do
		@controller_mock = mock.as_null_object
		@parser = ArgumentParser.new @controller_mock
	end
	
	it "should reject empty command" do
		lambda{@parser.parse []}.should raise_error
	end
	
	it "should reject unknown command" do
		lambda{@parser.parse "unknown command"}.should raise_error
	end
	
	it "should accept help command" do
		@controller_mock.should_receive(:help).with(nil)
		@parser.parse ["help"]
	end
	
	it "should accept start command" do
		@controller_mock.should_receive(:start).with "aCommand", "aFile"
		@parser.parse ["start", "aCommand","aFile"]
	end
	
	it "should prepend *.sh start scripts with 'bash'" do
		@controller_mock.should_receive(:start).with "bash aCommand.sh", "aFile"
		@parser.parse ["start", "aCommand.sh","aFile"]		
	end
	
	it "should prepend *.bat start scripts with 'start'" do
		@controller_mock.should_receive(:start).with "start aCommand.bat", "aFile"
		@parser.parse ["start", "aCommand.bat","aFile"]		
	end
	
	it "should prepend *.cmd start scripts with 'start'" do
		@controller_mock.should_receive(:start).with "start aCommand.cmd", "aFile"
		@parser.parse ["start", "aCommand.cmd","aFile"]		
	end
	
	it "should accept upload command" do
		@controller_mock.should_receive(:upload).with "framework", "dir"
		@parser.parse ["upload", "framework", "dir"]
	end
	
	it "should accept uppercase commands" do
		@controller_mock.should_receive(:help).with(nil)
		@parser.parse ["HELP"]
	end

end

