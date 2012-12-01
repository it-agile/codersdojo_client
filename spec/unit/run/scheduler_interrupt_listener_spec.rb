require 'flote/scheduler'
require 'run/scheduler_interrupt_listener'

describe SchedulerInterruptListener do
	CURRENT_PROCESS = 0

	before :each do
		@view_mock = mock('view')
		runner = mock.as_null_object
		@scheduler = Scheduler.new runner
		@scheduler.interrupt_listener = SchedulerInterruptListener.new @view_mock, []
	end

	it "should have no last action initially" do
		@scheduler.interrupt_listener.should_not be_last_action_was_exit
		@scheduler.interrupt_listener.should_not be_last_action_was_resume
	end

	# fails on MRI 1.9.3p327
	# working on MRI 1.8.x?
	it "should exit on Ctrl-C and 'e' (exit)" do
		@view_mock.should_receive :show_kata_exit_message
		@view_mock.should_receive(:read_user_input).and_return "e"
		@view_mock.should_receive :show_kata_upload_hint

	  Thread.new { @scheduler.start }
	  # Kills my whole X session when debugging it in RubyMine
	  Process.kill "INT", CURRENT_PROCESS
	  @scheduler.interrupt_listener.should be_last_action_was_exit
	end

	it "should execute command when the user pressed Ctrl-C and the command-key of the command" do
		@command_a_mock = mock
		@command_b_mock = mock
		@scheduler = Scheduler.new mock.as_null_object
		@scheduler.interrupt_listener = SchedulerInterruptListener.new @view_mock, [@command_a_mock, @command_b_mock]
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

