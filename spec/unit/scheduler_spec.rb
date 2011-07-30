require 'scheduler'

describe Scheduler do

	before :each do
		@view_mock = mock
		@scheduler = Scheduler.new mock.as_null_object, @view_mock, []
	end

	it "should have no last action initially" do
		@scheduler.last_action_was_exit?.should == false
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

	it "should execute command when the user pressed Ctrl-C and the command-key of the command" do
		@command_a_mock = mock
		@command_b_mock = mock
		@scheduler = Scheduler.new mock.as_null_object, @view_mock, [@command_a_mock, @command_b_mock]
		@view_mock.should_receive :show_kata_exit_message
		@view_mock.should_receive(:read_user_input).and_return 'b'
		@command_a_mock.should_receive(:command_key).and_return 'a'
		@command_b_mock.should_receive(:command_key).and_return 'b'
		@command_b_mock.should_receive(:execute)
		@command_b_mock.should_receive(:continue_test_loop?).and_return false

	  Thread.new { @scheduler.start }
	  Process.kill "INT", 0
	end	

end

