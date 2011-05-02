require 'controller'

describe Controller, "executing command setup" do

	before (:each) do
		@shell_mock = mock
		@view_mock = mock.as_null_object
		@scaffolder_mock = mock
		@command = UploadCommand.new @shell_mock, @view_mock, "my_host"
  end

	it "should use newest session dir if session dir is omitted" do
		@shell_mock.should_receive(:newest_dir_entry).and_return 'my-session'
		uploader_mock = mock
		uploader_mock.should_receive(:framework=).with 'a framework'
		uploader_mock.should_receive(:session_dir=).with '.codersdojo/my-session'
		uploader_mock.should_receive(:upload).and_return "find your kata here: my-url"
		@shell_mock.should_receive(:open_with_default_app).with "my-url"
		@command.uploader = uploader_mock
		@command.upload "a framework", nil
	end

end
