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
    @state_reader.session_id = "id0815"
  end

  it "should read a stored kata state" do
    @shell_mock.should_receive(:ctime).with("#{STATE_DIR_PREFIX}0").and_return @a_time
    Dir.should_receive(:entries).with("#{STATE_DIR_PREFIX}0").and_return(['.','..','file.rb', 'result.txt'])
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
  end

  it "should convert session-dir to session-id" do
    @state_reader_mock.should_receive(:session_id=).with("session_id")
    Uploader.new ".codersdojo/session_id", @state_reader_mock
  end

    context'upload' do

      before (:each) do
        @state_reader_mock = mock StateReader
        @state_reader_mock.should_receive(:session_id=).with("path_to_kata")
        @uploader = Uploader.new "path_to_kata", @state_reader_mock
      end

      it "should return error message if rest-client not installed" do
        @uploader.stub(:require).and_raise(LoadError)
        message = @uploader.upload
        message.should == 'Cant find gem rest-client. Please install it.'
      end


      it "should upload a kata through a rest-interface" do
        RestClient.should_receive(:post).with('http://www.codersdojo.com/katas', []).and_return '<id>222</id>'
        @uploader.upload_kata
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

      context 'states' do
        it "should read all states and starts/ends progress" do
          @state_reader_mock.should_receive(:state_count).and_return(1)
          Progress.should_receive(:wirite_empty_progress).with(1)

          @state_reader_mock.should_receive(:has_next_state).and_return 'true'
          @uploader.should_receive(:upload_state)
          @state_reader_mock.should_receive(:has_next_state).and_return nil

          Progress.should_receive(:end)

          @uploader.upload_states "kata_id"
        end


        it "through a rest interface and log process" do
          state = mock State
          @state_reader_mock.should_receive(:read_next_state).and_return state
          state.should_receive(:code).and_return 'code'
          state.should_receive(:time).and_return 'time'
          RestClient.should_receive(:post).with('http://www.codersdojo.com/katas/kata_id/states', {:code=> 'code', :created_at=>'time'})
          Progress.should_receive(:next)
          @uploader.upload_state "kata_id"
        end

      end

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
		@controller_mock.should_receive(:help).with()
		@parser.parse ["help"]
	end
	
	it "should accept start command" do
		@controller_mock.should_receive(:start).with()
		@parser.parse ["start"]
	end
	
	it "should accept upload command" do
		@controller_mock.should_receive(:upload).with [1,2]
		@parser.parse ["upload", 1, 2]
	end
	
	it "should accept uppercase commands" do
		@controller_mock.should_receive(:help).with()
		@parser.parse ["HELP"]
	end

end

describe Progress do

  it 'should print infos and empty progress in initialization' do
    STDOUT.should_receive(:print).with("2 states to upload")
    STDOUT.should_receive(:print).with("[  ]")
    STDOUT.should_receive(:print).with("\b\b\b")
    Progress.wirite_empty_progress 2
  end

  it 'should print dots and flush in next' do
    STDOUT.should_receive(:print).with(".")
    STDOUT.should_receive(:flush) 
    Progress.next
  end

  it 'should print empty line in end' do
    STDOUT.should_receive(:puts)
    Progress.end
  end

end
