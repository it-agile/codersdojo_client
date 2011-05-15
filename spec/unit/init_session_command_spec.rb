require 'init_session_command'

describe InitSessionCommand do

	before (:each) do
		@shell_mock = mock
		@view_mock = mock
		@command = InitSessionCommand.new @shell_mock, @view_mock
  end

	it "should create new session directory with unique ID" do
		@shell_mock.should_receive(:mkdir_p)
		@view_mock.should_receive(:show_init_session_result)
		@command.execute_from_shell [] 
	end

end
