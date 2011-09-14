require 'meta_config_file'
require 'scheduler'

class StartCommand
	
	def initialize meta_config_file, runner, view, eval_loop_commands
		@runner = runner
		@view = view
		@meta_file = meta_config_file
		@eval_loop_commands = eval_loop_commands
	end
	
	def execute_from_shell params
		start params[1], params[2]
	end

	def start command, file
		unless command then @view.show_missing_command_argument_error "start", "shell_command"; return end
		if file then @view.show_deprecated_command_argument_warning "start", "kata_file" end # since 30-may-2011, remove argument in later version
	  @view.show_start_kata command, file, @meta_file.framework_property
		@runner.source_files = @meta_file.source_files
	  @runner.run_command = command
	  scheduler = Scheduler.new @runner, @view, @eval_loop_commands
	  scheduler.start
	end
	
	def accepts_shell_command? command
		command == 'start'
	end
	
	def continue_test_loop?
		true
	end
	
end