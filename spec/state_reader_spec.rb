require 'state_reader'
require 'filename_formatter'

describe StateReader do

  before (:each) do
    @a_time = Time.new
    @shell_mock = mock
    @state_reader = StateReader.new @shell_mock
    @state_reader.session_id = "id0815"
		@state_dir_prefix = FilenameFormatter.state_dir_prefix
  end

  it "should read a stored kata state" do
    @shell_mock.should_receive(:creation_time).with(".codersdojo/id0815/#{@state_dir_prefix}0").and_return @a_time
    Dir.should_receive(:entries).with(".codersdojo/id0815/#{@state_dir_prefix}0").and_return(['.','..','file.rb', 'result.txt'])
    @shell_mock.should_receive(:read_file).with(".codersdojo/id0815/#{@state_dir_prefix}0/result.txt").and_return "result"
    @shell_mock.should_receive(:read_file).with(".codersdojo/id0815/#{@state_dir_prefix}0/file.rb").and_return "source code"
    state = @state_reader.read_next_state
    state.time.should == @a_time
    state.code.should == "source code"
    state.result.should == "result"
    @state_reader.next_step.should == 1
  end

end

