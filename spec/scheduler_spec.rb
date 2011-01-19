require 'scheduler'

describe Scheduler do

	before (:each) do
	  @old_handler = trap("INT", "IGNORE")
	end
	
	after (:each) do
	  trap("INT", @old_handler)
	  @thread.terminate
	end
	
	it "should exit on Ctrl-C" do
	  runner = mock.as_null_object
    runner.should_receive(:start) {
  	  Process.kill "INT", 0      
    }	  
	  
		scheduler = Scheduler.new runner
    scheduler.should_receive(:exit)

	  @thread = Thread.new { scheduler.start }
	end	

end

