require 'start_command'

describe StartCommand do

	before (:each) do
		@shell_mock = mock
		@view_mock = mock.as_null_object
		@upload_command_mock = mock
		@command = StartCommand.new @shell_mock, @view_mock, @upload_command_mock
  end

	it "should start scheduler" do
		@shell_mock.should_receive(:read_properties).with('.meta').and_return 'aFramework'
		@shell_mock.should_receive(:expand_run_command)
		scheduler_mock = mock
		Scheduler.should_receive(:new).and_return scheduler_mock
		scheduler_mock.should_receive(:start)
		@command.start 'aCommand.sh', 'primes.rb'
	end
	


end
