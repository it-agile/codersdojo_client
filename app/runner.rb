require "info_property_file"
require "filename_formatter"
require "text_converter"

class Runner

  attr_accessor :file # deprecated
  attr_accessor :source_files, :run_command

  def initialize shell, session_provider, view
    @filename_formatter = FilenameFormatter.new
    @shell = shell
    @session_provider = session_provider
		@view = view
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
		files = @shell.files_in_dir_tree '.', @source_files
		newest_dir_entry = @shell.newest_dir_entry '.', files
    change_time = @shell.modification_time newest_dir_entry
    if change_time == @previous_change_time then
	 	  Progress.next
      return
    end
    Progress.end
		@view.show_run_once_message newest_dir_entry, change_time
		execute_once @file, @session_id, @step
    @step += 1
    @previous_change_time = change_time
  end

	def execute_once file, session_id, step
		process = @shell.execute @run_command
		result = TextConverter.new.remove_escape_sequences process.output
    state_dir = @filename_formatter.state_dir session_id, step
    @shell.mkdir state_dir
    @shell.cp file, state_dir
    @shell.write_file @filename_formatter.result_file(state_dir), result
    @shell.write_file @filename_formatter.info_file(state_dir), "#{InfoPropertyFile.RETURN_CODE_PROPERTY}: #{process.return_code}"
	end
	
	def run_command= command
		@run_command = @shell.expand_run_command command
	end

end

