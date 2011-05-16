require 'runner'

class CaptureSingleRunCommand

	COMMAND_NAME = 'capture-single-run'

	def initialize shell, view
		@shell = shell
		@view = view
	end

	def execute_from_shell params
		unless params[1] then @view.show_missing_command_argument_error COMMAND_NAME, "shell_command"; return end
		unless params[2] then @view.show_missing_command_argument_error COMMAND_NAME, "kata_file"; return end
		capture_single_run params[1], params[2]
	end

	def capture_single_run run_command, kata_file
		runner = Runner.new @shell, SessionIdGenerator.new
		runner.run_command = run_command
		session_id = @shell.newest_dir_entry(FilenameFormatter.codersdojo_workspace) 
		filename_formatter = FilenameFormatter.new
		last_state_dir = @shell.newest_dir_entry(filename_formatter.session_dir session_id)
		step = last_state_dir.nil? ? 0 : filename_formatter.step_number_from_state_dir(last_state_dir) + 1
		runner.execute_once kata_file, session_id, step
	end

	def accepts_shell_command? command
		command == COMMAND_NAME
	end
		
end
