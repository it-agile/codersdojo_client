require 'state'
require 'revert_to_green_command'

describe RevertToGreenCommand do

	before (:each) do
		@shell_mock = mock
		@view_mock = mock.as_null_object
		@meta_config_file = mock
		@state_reader_mock = mock
		@command = RevertToGreenCommand.new @shell_mock, @view_mock, @meta_config_file, @state_reader_mock
		@green_state = State.new
		@green_state.return_code = 0 
		@green_state.files = ['my_file_1.rb', 'my_file_2.rb']
		@red_state = State.new
		@red_state.return_code = 256
		@shell_mock.should_receive(:newest_dir_entry).with(".codersdojo").and_return "does_not_matter"
		@state_reader_mock.should_receive(:session_dir=).with ".codersdojo/does_not_matter"
  end

	it "should do nothing if there is no state" do
		@state_reader_mock.should_receive(:goto_last_state)
		@state_reader_mock.should_receive(:state_exist?).and_return(false)
		@state_reader_mock.should_receive(:state_exist?).and_return(false)
 		@state_reader_mock.should_receive(:state_exist?).and_return(false)
		@state_reader_mock.should_receive(:goto_last_state)
		@command.revert_to_green
	end

	it "should do nothing if there was no previous green state" do
		@state_reader_mock.should_receive(:goto_last_state)
		@state_reader_mock.should_receive(:state_exist?).and_return(true)
		@state_reader_mock.should_receive(:read_previous_state).and_return @red_state
		@state_reader_mock.should_receive(:state_exist?).twice.and_return(false)
		@state_reader_mock.should_receive(:goto_last_state)
		@command.revert_to_green
	end
 
  it "should revert to last green state" do
		@meta_config_file.should_receive(:source_files).and_return '.*\.rb'
		@state_reader_mock.should_receive(:state_exist?).any_number_of_times.and_return(true)
		@state_reader_mock.should_receive(:goto_last_state)
		@state_reader_mock.should_receive(:read_previous_state).and_return @red_state
		@state_reader_mock.should_receive(:read_previous_state).and_return @green_state
		@state_reader_mock.should_receive(:next_step).and_return 1
		@shell_mock.should_receive(:rm_r).with('.*\.rb')
		@shell_mock.should_receive(:read_file).and_return('my code 1')
		@shell_mock.should_receive(:write_file).with('my_file_1.rb', 'my code 1')
		@shell_mock.should_receive(:read_file).and_return('my code 2')
		@shell_mock.should_receive(:write_file).with('my_file_2.rb', 'my code 2')
		@command.revert_to_green
	end
	
end
