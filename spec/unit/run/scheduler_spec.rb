require 'run/scheduler'

describe Scheduler do

	before :each do
		@listener_mock = mock.as_null_object
		@scheduler = Scheduler.new mock.as_null_object
		@scheduler.interrupt_listener = @listener_mock
	end

	it "should exit on Ctrl-C" do
		@listener_mock.should_receive :interrupt

	  Thread.new { @scheduler.start }
	  Process.kill "INT", 0
	end	

end

