require 'commands/start_command'

describe StartCommand do

	before (:each) do
		@view_mock = mock.as_null_object
		@upload_command_mock = mock
		@runner_mock = mock
		@meta_config_file_mock = mock
		@command = StartCommand.new @meta_config_file_mock, @runner_mock, @view_mock, [@upload_command_mock]
  end

	it "should start scheduler" do
		@meta_config_file_mock.should_receive(:framework_property).and_return 'aFramework'
		@meta_config_file_mock.should_receive(:source_files).and_return '.*'
		@runner_mock.should_receive(:source_files=).with '.*'
		@runner_mock.should_receive(:run_command=).with 'aCommand.sh'
		scheduler_mock = mock
		Scheduler.should_receive(:new).and_return scheduler_mock
		scheduler_mock.should_receive(:interrupt_listener=)
		scheduler_mock.should_receive(:start)
		@command.start 'aCommand.sh', 'primes.rb'
	end
	
end
