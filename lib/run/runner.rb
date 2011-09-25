require "info_property_file"
require "filename_formatter"
require "record/state_recorder"

class Runner

  attr_accessor :source_files, :run_command

	WORKING_DIR = '.'

  def initialize shell, session_id_generator, view, meta_config_file
	  @filename_formatter = FilenameFormatter.new
    @shell = shell
    @session_id_generator = session_id_generator
		@view = view
		@meta_config_file = meta_config_file
  end

  def start
		@state_recorder = StateRecorder.new(@shell, @session_id_generator, @meta_config_file)
    init_session 
    execute
  end

  def init_session
	  @state_recorder.init_session
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
		execute_once files
    @previous_change_time = change_time
  end

	def execute_once files
		process = @shell.execute @run_command
		@state_recorder.record_state files, process
	end
	
	def run_command= command
		@run_command = @shell.expand_run_command command
	end

end

