require 'session_id_generator'
require 'runner'
require 'shell_argument_exception'
require 'shell_wrapper'
require 'console_view'
require 'return_code_evaluator'
require 'state_reader'
require 'commands/help_command'
require 'commands/xhelp_command'
require 'commands/generate_command'
require 'commands/init_session_command'
require 'commands/capture_single_run_command'
require 'commands/revert_to_green_command'
require 'commands/upload_command'
require 'commands/upload_no_open_command'
require 'commands/start_command'

class ArgumentParser
	
	def initialize shell, view, scaffolder, hostname
		meta_config_file = MetaConfigFile.new shell
		return_code_evaluator = ReturnCodeEvaluator.new meta_config_file.success_detection
		runner = Runner.new shell, SessionIdGenerator.new, view, return_code_evaluator
		@help_command = HelpCommand.new view
		@xhelp_command = XHelpCommand.new view
		@generate_command = GenerateCommand.new shell, view, scaffolder
		@upload_command = UploadCommand.new shell, view, hostname
		@upload_no_open_command = UploadNoOpenCommand.new @upload_command
		@init_session_command = InitSessionCommand.new view, runner
		@capture_single_run_command = CaptureSingleRunCommand.new shell, view, runner
		@revert_to_green_command = RevertToGreenCommand.new shell, view, meta_config_file, StateReader.new(shell)
		@start_command = StartCommand.new meta_config_file, runner, view, [@upload_command, @revert_to_green_command]
		@commands = [@help_command, @xhelp_command, @generate_command, @init_session_command, 
			@capture_single_run_command, @start_command, @revert_to_green_command,
			@upload_command, @upload_no_open_command]
	end
	
	def parse params
		params[0] = params[0] ? params[0].downcase : 'help'
		command_name = params[0]
		command_executed = false
		@commands.each do |command|
			if command.accepts_shell_command?(command_name) 
				command.execute_from_shell params
				command_executed = true
			end
		end
		if not command_executed and command_name == "spec"
			# 'spec" is for testing purpose only: do nothing special
		elsif not command_executed
			raise ShellArgumentException.new command_name
		end
	end

end

