require 'scheduler'

describe Scheduler do

	it "should exit on Ctrl-C" do
		scheduler = Scheduler.new mock.as_null_object
    scheduler.should_receive(:exit)

	  Thread.new { scheduler.start }
	  Process.kill "INT", 0      
	end	

end

