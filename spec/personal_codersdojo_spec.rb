ARGV[0] = "spec" # to be first line to suppress help text output of shell command
require 'rubygems'
require "../app/personal_codersdojo"
require "restclient"
require "spec"


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

describe StateReader do

  before (:each) do
    @a_time = Time.new
    @shell_mock = mock
    @state_reader = StateReader.new @shell_mock
    @state_reader.source_code_file = "file.rb"
    @state_reader.session_id = "id0815"
  end

  it "should read a stored kata state" do
    @shell_mock.should_receive(:ctime).with("#{STATE_DIR_PREFIX}0").and_return @a_time
    @shell_mock.should_receive(:read_file).with("#{STATE_DIR_PREFIX}0/file.rb").and_return "source code"
    @shell_mock.should_receive(:read_file).with("#{STATE_DIR_PREFIX}0/result.txt").and_return "result"
    state = @state_reader.read_next_state
    state.time.should == @a_time
    state.code.should == "source code"
    state.result.should == "result"
    @state_reader.next_step.should == 1
  end
end

describe Uploader do

  before (:each) do
    @state_reader_mock = mock StateReader
    @state_reader_mock.should_receive(:source_code_file=).with("ruby.file")
    @state_reader_mock.should_receive(:session_id=).with("session")
    @uploader = Uploader.new "ruby.file", "session", @state_reader_mock
  end

  it "should upload a kata through a rest-interface" do
    RestClient.should_receive(:post).with('http://www.codersdojo.com/katas', []).and_return '<id>222</id>'
    @uploader.upload_kata
  end

  it "should upload states throug a rest interface" do
    state = mock State
    @state_reader_mock.should_receive(:has_next_state).and_return 'true'
    @state_reader_mock.should_receive(:read_next_state).and_return state
    state.should_receive(:code).and_return 'code'
    state.should_receive(:time).and_return 'time'
    RestClient.should_receive(:post).with('http://www.codersdojo.com/katas/kata_id/states', {:code=> 'code', :created_at=>'time'})

    @state_reader_mock.should_receive(:has_next_state).and_return nil
    @uploader.upload_states "kata_id"
  end

  it "should upload kata and states" do
    @uploader.stub(:upload_kata).and_return 'kata_xml'
    XMLElementExtractor.should_receive(:extract).with('kata/id', 'kata_xml').and_return 'kata_id'
    @uploader.stub(:upload_states).with 'kata_id'
    XMLElementExtractor.should_receive(:extract).with('kata/short-url', 'kata_xml').and_return 'short_url'
    @uploader.upload_kata_and_states
  end

  it 'should upload if enugh states are there' do
      @state_reader_mock.should_receive(:enough_states?).and_return 'true'
      @uploader.stub!(:upload_kata_and_states).and_return 'kata_link'
      @uploader.upload
  end

  it 'should return a helptext if not enught states are there' do
      @state_reader_mock.should_receive(:enough_states?).and_return nil
      help_text = @uploader.upload
      help_text.should == 'You need at least two states'
  end

end

describe XMLElementExtractor do
	
  it "should extract first element from a xml string" do
    xmlString = "<?xml version='1.0' encoding='UTF-8'?>\n<kata>\n  <created-at type='datetime'>2010-07-16T16:02:00+02:00</created-at>\n  <end-date type='datetime' nil='true'/>\n  <id type='integer'>60</id>\n  <short-url nil='true'/>\n  <updated-at type='datetime'>2010-07-16T16:02:00+02:00</updated-at>\n  <uuid>2a5a83dc71b8ad6565bd99f15d01e41ec1a8f3f2</uuid>\n</kata>\n"
    element = XMLElementExtractor.extract 'kata/id', xmlString
    element.should == "60"
  end

end

describe ArgumentParser do
	
	before (:each) do
		@parser = ArgumentParser.new
	end
	
	it "should reject empty or unknown commands" do
	  command = @parser.parse []
	  command.should == nil
	end
	
	it "should reject unknown command" do
		command = @parser.parse ["unknown_command"]
		command.should == nil
	end
	
	it "should accept commands help, start, upload" do
		["help", "start", "upload"].each do |command|
			result = @parser.parse [command]
			result.should == command
		end
	end
	
end
