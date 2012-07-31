require 'commands/init_session_command'

describe InitSessionCommand do

  before (:each) do
    @shell_mock = mock
    @view_mock = mock
    @runner = mock
    @command = InitSessionCommand.new @view_mock, @runner
  end

  it "should create new session directory with unique ID" do
    @runner.should_receive(:init_session)
    @view_mock.should_receive(:show_init_session_result)
    @command.execute_from_shell []
  end

end
