require "info_property_file"
require "filename_formatter"
require "text_converter"

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
		session_dir = @filename_formatter.session_dir @session_id
    @shell.mkdir_p(session_dir)
		session_dir
  end

  def execute
    change_time = @shell.modification_time @file
    if change_time == @previous_change_time then
	 	  Progress.next
      return
    end
    Progress.end
    process = @shell.execute @run_command
		result = TextConverter.new.remove_escape_sequences process.output
    state_dir = @filename_formatter.state_dir @session_id, @step
    @shell.mkdir state_dir
    @shell.cp @file, state_dir
    @shell.write_file @filename_formatter.result_file(state_dir), result
    @shell.write_file @filename_formatter.info_file(state_dir), "#{InfoPropertyFile.RETURN_CODE_PROPERTY}: #{process.return_code}"
    @step += 1
    @previous_change_time = change_time
  end

end

