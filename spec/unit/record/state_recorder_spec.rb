require "rspec/mocks/argument_matchers"
require 'record/state_recorder'

def regex_matcher regex
	RSpec::Mocks::ArgumentMatchers::RegexpMatcher.new regex
end

describe StateRecorder do

  WORKSPACE = FilenameFormatter::CODERSDOJO_WORKSPACE
  SESSION_ID = "session_id"
  SESSION_DIR = "#{WORKSPACE}/#{SESSION_ID}"
  STATE_0_DIR = "#{SESSION_DIR}/state_0"
	
  before (:each) do
    @shell_mock = mock.as_null_object
	  @process_mock = mock.as_null_object
    @session_id_generator_mock = mock.as_null_object
    @meta_config_file_mock = mock.as_null_object
    @meta_config_file_mock.stub(:success_detection).and_return(false)
		@state_recorder = StateRecorder.new @shell_mock, @session_id_generator_mock, @meta_config_file_mock
    @state_recorder.session_id = "session_id"
    @state_recorder.step = 0
  end

  it "should create a session directory" do
    @session_id_generator_mock.should_receive(:generate_id).and_return "my_session"
	  @shell_mock.should_receive(:mkdir_p).with "#{WORKSPACE}/my_session"	
	  @state_recorder.init_session
	end
	
	it "should reset the step counter when a new session is initialized" do
		@state_recorder.step = nil
	  @state_recorder.init_session
	  @state_recorder.step.should == 0
	end

  it "should create a directory per state" do
	  @shell_mock.should_receive(:mkdir).with regex_matcher(/#{STATE_0_DIR}.*/)
	  @state_recorder.record_state [], @process_mock
  end

  it "should copy the source file to the state directory" do
		  @shell_mock.should_receive(:cp_r).with ["file1", "file2"], regex_matcher(/#{STATE_0_DIR}.*/)
		  @state_recorder.record_state ["file1", "file2"], @process_mock
  end

  it "should write the process output into the state directory" do
      @process_mock.should_receive(:output).and_return "process output"
			@shell_mock.should_receive(:write_file).with regex_matcher(/.*\/result.txt/), "process output"
			@state_recorder.record_state [], @process_mock
	end
	
	it "should write the process return code into the info file" do
    @process_mock.should_receive(:return_code).and_return 1
		@shell_mock.should_receive(:write_file).with regex_matcher(/.*\/info.yml/), regex_matcher(/.*return_code: 1.*/)
		@state_recorder.record_state [], @process_mock
	end

	it "should write the timestamp into the info file" do
		a_time = Time.mktime 2011, 9, 17, 14, 49, 59
		Time.should_receive(:new).and_return a_time    
		@shell_mock.should_receive(:write_file).with regex_matcher(/.*\/info.yml/), regex_matcher(/.*date: '2011-09-17'\ntime: '14:49:59'.*/)
		@state_recorder.record_state [], @process_mock
	end

	it "should write the step number into the info file" do
		@state_recorder.step = 2
		@shell_mock.should_receive(:write_file).with regex_matcher(/.*\/info.yml/), regex_matcher(/.*step: 2.*/)
		@state_recorder.record_state [], @process_mock
	end

  it "should start counting steps at 0" do
	  @state_recorder.step.should == 0
	end
	
  it "should increase the step number after each state recording" do
		  @state_recorder.record_state [], @process_mock
		  @state_recorder.step.should == 1
		  @state_recorder.record_state [], @process_mock
		  @state_recorder.step.should == 2
	end

end
