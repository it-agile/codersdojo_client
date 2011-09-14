require "info_property_file"
require "filename_formatter"
require "run/text_converter"
require "record/return_code_evaluator"

class Runner

  attr_accessor :source_files, :run_command

	WORKING_DIR = '.'

  def initialize shell, session_provider, view, return_code_evaluator
    @filename_formatter = FilenameFormatter.new
    @shell = shell
    @session_provider = session_provider
		@view = view
		@return_code_evaluator = return_code_evaluator
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
		files = @shell.files_in_dir_tree WORKING_DIR, @source_files
		newest_dir_entry = @shell.newest_dir_entry WORKING_DIR, files
    change_time = @shell.modification_time newest_dir_entry
    if change_time == @previous_change_time then
	 	  Progress.next
      return
    end
    Progress.end
		@view.show_run_once_message newest_dir_entry, change_time
		execute_once files, @session_id, @step
    @step += 1
    @previous_change_time = change_time
  end

	def execute_once files, session_id, step
		process = @shell.execute @run_command
		result = TextConverter.new.remove_escape_sequences process.output
    state_dir = @filename_formatter.state_dir session_id, step
    return_code = @return_code_evaluator.return_code(process)
    @shell.mkdir state_dir
    @shell.cp_r files, state_dir
    @shell.write_file @filename_formatter.result_file(state_dir), result
    @shell.write_file @filename_formatter.info_file(state_dir), "#{InfoPropertyFile.RETURN_CODE_PROPERTY}: #{return_code}"
	end
	
	def run_command= command
		@run_command = @shell.expand_run_command command
	end

end

