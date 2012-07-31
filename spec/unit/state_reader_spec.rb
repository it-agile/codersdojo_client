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
    @state_reader.next_step.should == 0
    state = @state_reader.read_state
    state.time.should == @a_time
    state.files.should == ["file.rb"]
    state.file_contents.should == ["========== file.rb ==========\n\nsource code"]
    state.result.should == "result"
    state.return_code.should == 256
    @state_reader.next_step.should == 0
  end

  it "should read previous stored kata state" do
    state = mock
    @state_reader.should_receive(:read_state).and_return state
    @state_reader.next_step = 3
    state = @state_reader.read_previous_state
    state.should == state
    @state_reader.next_step.should == 2
  end

  it "should read next stored kata state" do
    state = mock
    @state_reader.should_receive(:read_state).and_return state
    @state_reader.next_step = 2
    state = @state_reader.read_next_state
    state.should == state
    @state_reader.next_step.should == 3
  end

  it "should check if state exists" do
    @state_reader.should_receive(:get_state_dir).with(1).and_return 'state_1'
    File.should_receive(:exist?).with('state_1').and_return true
    @state_reader.state_exist?(1).should == true
    @state_reader.should_receive(:get_state_dir).with(2).and_return 'state_2'
    File.should_receive(:exist?).with('state_2').and_return false
    @state_reader.state_exist?(2).should == false
  end

  it "should check if next state exists" do
    @state_reader.next_step = 1
    @state_reader.should_receive(:get_state_dir).with(1).and_return 'state_1'
    File.should_receive(:exist?).with('state_1').and_return false
    @state_reader.has_next_state.should == false
  end

  it "should go to the last state" do
    File.should_receive(:exist?).and_return true
    File.should_receive(:exist?).and_return true
    File.should_receive(:exist?).and_return false
    @state_reader.goto_last_state
    @state_reader.next_step.should == 1
  end

end

