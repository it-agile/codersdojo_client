require 'meta_config_file'
require 'scheduler'

class StartCommand
	
	def initialize shell, view, upload_command
		@shell = shell
		@view = view
		@meta_file = MetaConfigFile.new @shell
		@upload_command = upload_command
	end
	
	def execute_from_shell params
		start params[1], params[2]
	end

	def start command, file
		unless command then @view.show_missing_command_argument_error "start", "shell_command"; return end
		unless file then @view.show_missing_command_argument_error "start", "kata_file"; return end
		command = expand_run_command command
	  @view.show_start_kata command, file, @meta_file.framework_property
	  dojo = Runner.new @shell, SessionIdGenerator.new
	  dojo.file = file
	  dojo.run_command = command
	  scheduler = Scheduler.new dojo, @view, [@upload_command]
	  scheduler.start
	end
	
	def accepts_shell_command? command
		command == 'start'
	end
	
	def expand_run_command command
		if command.end_with?(".sh") then
			"bash #{command}"
		else
			command
		end
	end
	
end