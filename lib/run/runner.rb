class Runner

  attr_accessor :source_files, :run_command, :init_session_callback, :execute_callback

	WORKING_DIR = '.'

  def initialize shell, view
    @shell = shell
		@view = view
  end

  def start
	  if @init_session_callback then @init_session_callback.call end
    execute
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
		if @execute_callback then @execute_callback.call(files, process) end
	end
	
	def run_command= command
		@run_command = @shell.expand_run_command command
	end

end

