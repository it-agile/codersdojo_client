require 'uploader'

describe Uploader do

  before (:each) do
    @state_reader_mock = mock StateReader
  end

  it "should convert session-dir to session-id" do
    @state_reader_mock.should_receive(:session_id=).with("session_id")
    Uploader.new "http://dummy_host", "dummy.framework", ".codersdojo/session_id", @state_reader_mock
  end

    context'upload' do

      before (:each) do
        @state_reader_mock = mock StateReader
        @state_reader_mock.should_receive(:session_id=).with("path_to_kata")
        @uploader = Uploader.new "http://dummy_host", "dummy.framework", "path_to_kata", @state_reader_mock
      end

      it "should upload a kata through a rest-interface" do
        RestClient.should_receive(:post).with('http://dummy_host/katas', {:framework => "dummy.framework"}).and_return '<id>222</id>'
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
          Progress.should_receive(:write_empty_progress).with(1)

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
          state.should_receive(:result).and_return 'result'
          RestClient.should_receive(:post).with('http://dummy_host/katas/kata_id/states', {:code=> 'code', :result => 'result', :created_at => 'time'})
          Progress.should_receive(:next)
          @uploader.upload_state "kata_id"
        end

      end

    end

  end

