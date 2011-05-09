require 'start_command'

describe StartCommand do

	before (:each) do
		@shell_mock = mock
		@view_mock = mock.as_null_object
		@upload_command_mock = mock
		@command = StartCommand.new @shell_mock, @view_mock, @upload_command_mock
  end

	it "should prepend *.sh start scripts with 'bash'" do
		@command.expand_run_command('aCommand.sh').should == 'bash aCommand.sh'
	end
	
	it "should not prepend *.bat start scripts with anything" do
		@command.expand_run_command('aCommand.bat').should == 'aCommand.bat'
	end
	
	it "should not prepend *.cmd start scripts with anything" do
		@command.expand_run_command('aCommand.cmd').should == 'aCommand.cmd'
	end
	
	it "should start scheduler" do
		@shell_mock.should_receive(:read_properties).with('.meta').and_return 'aFramework'
		scheduler_mock = mock
		Scheduler.should_receive(:new).and_return scheduler_mock
		scheduler_mock.should_receive(:start)
		@command.start 'aCommand.sh', 'primes.rb'
	end
	


end
