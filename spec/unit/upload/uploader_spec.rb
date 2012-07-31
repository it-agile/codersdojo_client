require 'upload/uploader'

describe Uploader do

  before (:each) do
    @state_reader_mock = mock StateReader
  end

  it "should convert session-dir to session-id" do
    @state_reader_mock.should_receive(:session_dir=).with(".codersdojo/session_id")
    Uploader.new "http://dummy_host", "dummy.framework", ".codersdojo/session_id", @state_reader_mock
  end

  context'upload' do

    before (:each) do
      @state_reader_mock = mock StateReader
      @state_reader_mock.should_receive(:session_dir=).with("path_to_kata")
      @uploader = Uploader.new "http://dummy_host", "dummy.framework", "path_to_kata", @state_reader_mock
    end

    it "should upload a kata through a rest-interface" do
      RestClient.should_receive(:post).with('http://dummy_host/katas', {:framework => "dummy.framework"}).and_return '<id>222</id>'
      @uploader.upload_kata
    end

    it "should upload kata and states" do
      @uploader.stub(:states).and_return [State.new, State.new]
      @uploader.stub(:read_states)
      @uploader.stub(:upload_kata).and_return 'kata_xml'
      XMLElementExtractor.should_receive(:extract).with('kata/private-uuid', 'kata_xml').and_return 'describe_url'
      @uploader.upload_kata_and_states
    end

    it 'should upload if enough states are there' do
      @state_reader_mock.should_receive(:enough_states?).and_return 'true'
      @uploader.stub!(:upload_kata_and_states).and_return 'kata_link'
      @uploader.upload
    end

    it 'should return a helptext if not enught states are there' do
      @state_reader_mock.should_receive(:enough_states?).and_return nil
      help_text = @uploader.upload
      help_text.should == 'You need at least two states'
    end

    it "through a rest interface and log process" do
      states = [(mock State), (mock State)]
      states.each_with_index {|state, index|
        state.should_receive(:file_contents).and_return ["code#{index}"]
        state.should_receive(:time).and_return "time#{index}"
        state.should_receive(:result).and_return "result#{index}"
        state.should_receive(:green?).and_return(index == 0)
      }
      @state_reader_mock.should_receive(:reset)
      @state_reader_mock.should_receive(:has_next_state).and_return true
      @state_reader_mock.should_receive(:read_next_state).and_return states[0]
      @state_reader_mock.should_receive(:has_next_state).and_return true
      @state_reader_mock.should_receive(:read_next_state).and_return states[1]
      @state_reader_mock.should_receive(:has_next_state).and_return false
      RestClient.should_receive(:post).with('http://dummy_host/katas',
                                            {"states[1]"=>{:created_at=>"time1", :result=>"result1", :code=>["code1"], :green => false},
                                              "states[0]"=>{:created_at=>"time0", :result=>"result0", :code=>["code0"], :green => true},
                                              :framework=>"dummy.framework"})
      @uploader.upload_kata_and_states
    end

  end

end

