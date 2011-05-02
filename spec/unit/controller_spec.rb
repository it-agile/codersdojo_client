require 'controller'

describe Controller, "executing command setup" do

	before (:each) do
		@shell_mock = mock
		@view_mock = mock.as_null_object
		@scaffolder_mock = mock
		@help_command_mock = mock
		@upload_command_mock = mock
		@generate_command_mock = mock
		@start_command_mock = mock
		HelpCommand.should_receive(:new).and_return @help_command_mock
		GenerateCommand.should_receive(:new).and_return @generate_command_mock
		UploadCommand.should_receive(:new).and_return @upload_command_mock
		StartCommand.should_receive(:new).and_return @start_command_mock
		@controller = Controller.new @shell_mock, @view_mock, @scaffolder_mock, "my_host"
  end

	it "should delegate to help-command" do
		@help_command_mock.should_receive(:help).with "a command"
		@controller.help "a command"
	end

	it "should delegate to generate-command" do
		@generate_command_mock.should_receive(:generate).with "a framework", "a kata file"
		@controller.generate "a framework", "a kata file"
	end

	it "should delegate to upload-command" do
		@upload_command_mock.should_receive(:upload).with nil, "a session dir", true
		@controller.upload "a session dir"
	end

	it "should delegate to start-command" do
		@start_command_mock.should_receive(:start).with "a command", "a file"
		@controller.start "a command", "a file"
	end

end
