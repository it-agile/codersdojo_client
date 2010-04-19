require "app/personal_codersdojo"

describe PersonalCodersDojo do

	WORKSPACE_DIR = ".codersdojo"
	SESSION_ID = "id0815"
	SESSION_DIR = "#{WORKSPACE_DIR}/#{SESSION_ID}"

  before (:each) do
	  @shell_mock = mock.as_null_object
	  @session_id_provider_mock = mock.as_null_object
    @session_id_provider_mock.should_receive(:generate_id).and_return SESSION_ID 
	  @runner = PersonalCodersDojo.new @shell_mock, @session_id_provider_mock
	end
  
  it "should create codersdojo directory if it doesn't exist with session sub-directory" do
	  @shell_mock.should_receive(:mkdir_p).with SESSION_DIR
	  @runner.start
  end

  it "should run ruby command on kata file given as argument" do
	  @runner.file = "my_file.rb"
	  @shell_mock.should_receive(:execute).with "ruby my_file.rb"
	  @runner.start
	end
	
	it "should archive kata file in state directory" do
	  @runner.file = "my_file.rb"
	  state_dir = "#{SESSION_DIR}/state_0"
	  @shell_mock.should_receive(:mkdir).with state_dir
		@shell_mock.should_receive(:cp).with "my_file.rb", state_dir
		@runner.start
	end
  
end
