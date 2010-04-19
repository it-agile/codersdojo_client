require "app/personal_codersdojo"

describe PersonalCodersDojo do

	WORKSPACE_DIR = ".codersdojo"
	SESSION_ID = "id0815"
	SESSION_DIR = "#{WORKSPACE_DIR}/#{SESSION_ID}"
  STATE_DIR_PREFIX = "#{SESSION_DIR}/state_"

  before (:each) do
	  @shell_mock = mock.as_null_object
	  @session_id_provider_mock = mock.as_null_object
    @session_id_provider_mock.should_receive(:generate_id).and_return SESSION_ID 
	  @runner = PersonalCodersDojo.new @shell_mock, @session_id_provider_mock
	  @runner.file = "my_file.rb"
		@runner.run_command = "ruby"
	end
  
  it "should create codersdojo directory if it doesn't exist with session sub-directory" do
	  @shell_mock.should_receive(:mkdir_p).with SESSION_DIR
	  @runner.start
  end

  it "should run ruby command on kata file given as argument" do
	  @shell_mock.should_receive(:execute).with "ruby my_file.rb"
	  @runner.start
	end
	
  it "should create a state directory for every state" do
    @shell_mock.should_receive(:ctime).with("my_file.rb").and_return 1
    @shell_mock.should_receive(:mkdir).with "#{STATE_DIR_PREFIX}0"
	  @shell_mock.should_receive(:cp).with "my_file.rb", "#{STATE_DIR_PREFIX}0"
    @runner.start
    @shell_mock.should_receive(:ctime).with("my_file.rb").and_return 2
    @shell_mock.should_receive(:mkdir).with "#{STATE_DIR_PREFIX}1"
	  @shell_mock.should_receive(:cp).with "my_file.rb", "#{STATE_DIR_PREFIX}1"
    @runner.execute
  end

  it "should not run if the kata file wasn't modified" do
	  a_time = Time.new
    @shell_mock.should_receive(:ctime).with("my_file.rb").and_return a_time
    @shell_mock.should_receive(:mkdir).with "#{STATE_DIR_PREFIX}0"
	  @shell_mock.should_receive(:cp).with "my_file.rb", "#{STATE_DIR_PREFIX}0"
    @runner.start
    @shell_mock.should_receive(:ctime).with("my_file.rb").and_return a_time
    @shell_mock.should_not_receive(:mkdir).with "#{STATE_DIR_PREFIX}1"
	  @shell_mock.should_not_receive(:cp).with "my_file.rb", "#{STATE_DIR_PREFIX}1"
    @runner.execute
	end

  it "should capture run result into state directory" do
    @shell_mock.should_receive(:execute).and_return "spec result"
    @shell_mock.should_receive(:write_file).with "#{STATE_DIR_PREFIX}0/result.txt", "spec result"
    @runner.start
  end

end
