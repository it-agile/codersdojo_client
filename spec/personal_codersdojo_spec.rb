ARGV[0] = "spec" # to be first line to suppress help text output of shell command
require "app/personal_codersdojo"

describe PersonalCodersDojo, "in run mode" do

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

describe PersonalCodersDojo, "in upload mode" do

  SERVER_URL = "http://dummy.com"
  URL_PREFIX = "#{SERVER_URL}/restapi"

  before (:each) do
	  @a_time = Time.new
	  @shell_mock = mock
	  @api_mock = mock.as_null_object
	  @uploader = Uploader.new @shell_mock, SERVER_URL, @api_mock
	end
	
	it "should read a stored kata state" do
		@shell_mock.should_receive(:ctime).with("#{STATE_DIR_PREFIX}0").and_return @a_time
		@shell_mock.should_receive(:read_file).with("#{STATE_DIR_PREFIX}0/file.rb").and_return "source code"
		@shell_mock.should_receive(:read_file).with("#{STATE_DIR_PREFIX}0/result.txt").and_return "result"
		@uploader.session_id = "id0815"
		@uploader.next_step = 0
		@uploader.source_code_file = "file.rb"
		state = @uploader.read_next_state
		state.time.should == @a_time
		state.code.should == "source code"
		state.result.should == "result"
		@uploader.next_step.should == 1
	end
	
  it "should generate a kata uuid and use that for uploading kata states" do
	  @api_mock.should_receive(:get).with("#{URL_PREFIX}/uuid").and_return "1"
	  @api_mock.should_receive(:post).with("#{URL_PREFIX}/state", {:uuid => "1", :time => @a_time, :code => "source code", :result => "result"})
	  @uploader.init_upload
	  state = State.new @a_time, "source code", "result"
	  @uploader.upload_state state
	end	
	
end

