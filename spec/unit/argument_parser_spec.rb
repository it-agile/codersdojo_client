require 'argument_parser'

describe ArgumentParser do
	
	before (:each) do
		@shell_mock = mock
		@view_mock = mock.as_null_object
		@scaffolder_mock = mock
		@help_command_mock = mock.as_null_object
		@upload_command_mock = mock.as_null_object
		@generate_command_mock = mock.as_null_object
		@start_command_mock = mock.as_null_object
		HelpCommand.should_receive(:new).and_return @help_command_mock
		GenerateCommand.should_receive(:new).and_return @generate_command_mock
		UploadCommand.should_receive(:new).and_return @upload_command_mock
		StartCommand.should_receive(:new).and_return @start_command_mock
		
		@parser = ArgumentParser.new @shell_mock, @view_mock, @scaffolder_mock, "a host"
	end
	
	it "should reject unknown command" do
		lambda{@parser.parse "unknown command"}.should raise_error
	end
	
	it "should accept help command" do
		@help_command_mock.should_receive(:accepts_shell_command?).with("help").and_return true
		@help_command_mock.should_receive(:execute_from_shell).with ["help"]
		@parser.parse ["help"]
	end
	
	it "should accept empty command as help command" do
		@help_command_mock.should_receive(:accepts_shell_command?).with("help").and_return true
		@help_command_mock.should_receive(:execute_from_shell).with ["help"]
		@parser.parse []
	end
	
	it "should accept uppercase commands" do
		@help_command_mock.should_receive(:accepts_shell_command?).with("help").and_return true
		@help_command_mock.should_receive(:execute_from_shell).with ["help"]
		@parser.parse ["HELP"]
	end
	
	it "should delegate to help-command" do
		@help_command_mock.should_receive(:accepts_shell_command?).with("help").and_return true
		@help_command_mock.should_receive(:execute_from_shell).with ["help", "a command"]
		@parser.parse ["help", "a command"]
	end

end

