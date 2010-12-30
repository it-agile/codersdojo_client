require "filename_formatter"

class Runner

  attr_accessor :file, :run_command

  def initialize shell, session_provider
    @filename_formatter = FilenameFormatter.new
    @shell = shell
    @session_provider = session_provider
  end

  def start
    init_session
    execute
  end

  def init_session
    @step = 0
    @session_id = @session_provider.generate_id
    @shell.mkdir_p(@filename_formatter.session_dir @session_id)
  end

  def execute
    change_time = @shell.ctime @file
    if change_time == @previous_change_time then
      return
    end
    result = @shell.execute @run_command
    state_dir = @filename_formatter.state_dir @session_id, @step
    @shell.mkdir state_dir
    @shell.cp @file, state_dir
    @shell.write_file @filename_formatter.result_file(state_dir), result
    @step += 1
    @previous_change_time = change_time
  end

end

