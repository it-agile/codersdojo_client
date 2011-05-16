require 'capture_single_run_command'

describe CaptureSingleRunCommand do

	before (:each) do
		@shell_mock = mock
		@view_mock = mock
		@runner_mock = mock
		Runner.should_receive(:new).any_number_of_times.and_return(@runner_mock)
		@runner_mock.should_receive(:run_command=).any_number_of_times
		@command = CaptureSingleRunCommand.new @shell_mock, @view_mock
  end

	it "should enforce the shell_command parameter" do
		@view_mock.should_receive(:show_missing_command_argument_error).with('capture-single-run', 'shell_command')
		@command.execute_from_shell ['capture-single-run']
	end

	it "should enforce the kata_file parameter" do
		@view_mock.should_receive(:show_missing_command_argument_error).with('capture-single-run', 'kata_file')
		@command.execute_from_shell ['capture-single-run', 'aCommand']
	end

	it "should capture the first single run" do 
		@shell_mock.should_receive(:newest_dir_entry).with('.codersdojo').and_return '1234'
		@shell_mock.should_receive(:newest_dir_entry).with('.codersdojo/1234').and_return nil
		@runner_mock.should_receive(:execute_once).with('aFile', '1234', 0)
		@command.execute_from_shell ['capture-single-run', 'aCommand', 'aFile']
	end

	it "should capture subsequent single runs" do
		@shell_mock.should_receive(:newest_dir_entry).with('.codersdojo').and_return '1234'
		@shell_mock.should_receive(:newest_dir_entry).with('.codersdojo/1234').and_return 'state_2'
		@runner_mock.should_receive(:execute_once).with('aFile', '1234', 3)
		@command.execute_from_shell ['capture-single-run', 'aCommand', 'aFile']
	end

end
