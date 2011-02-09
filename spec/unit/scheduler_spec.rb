require 'scheduler'

describe Scheduler do

	before :each do
		@view_mock = mock
		@scheduler = Scheduler.new mock.as_null_object, @view_mock
	end

	it "should have no last action initially" do
		@scheduler.last_action_was_exit?.should == false
		@scheduler.last_action_was_upload?.should == false
		@scheduler.last_action_was_resume?.should == false
	end

	it "should exit on Ctrl-C and 'e' (exit)" do
		@view_mock.should_receive :show_kata_exit_message
		@view_mock.should_receive(:read_user_input).and_return "e"
		@view_mock.should_receive :show_kata_upload_hint

	  Thread.new { @scheduler.start }
	  Process.kill "INT", 0
	  @scheduler.last_action_was_exit?.should == true
	end	

	it "should upload on Ctrl-C and 'u' (upload)" do
		@view_mock.should_receive :show_kata_exit_message
		@view_mock.should_receive(:read_user_input).and_return "u"

	  Thread.new { @scheduler.start }
	  Process.kill "INT", 0
	  @scheduler.last_action_was_upload?.should == true
	end	

end

