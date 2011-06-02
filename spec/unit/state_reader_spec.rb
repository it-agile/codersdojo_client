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
    @shell_mock.should_receive(:files_in_dir_tree).with(".codersdojo/id0815/#{@state_dir_prefix}0").and_return(['.','..','file.rb', 'result.txt', 'info.yml'])
    @shell_mock.should_receive(:read_file).with(".codersdojo/id0815/#{@state_dir_prefix}0/result.txt").and_return "result"
    @shell_mock.should_receive(:read_file).with("file.rb").and_return "source code"
		@shell_mock.should_receive(:read_properties).with(".codersdojo/id0815/#{@state_dir_prefix}0/info.yml").and_return('return_code' => 256)
    state = @state_reader.read_next_state
    state.time.should == @a_time
    state.files.should == ["========== file.rb ==========\n\nsource code"]
    state.result.should == "result"
    state.return_code.should == 256
    @state_reader.next_step.should == 1
  end

end

