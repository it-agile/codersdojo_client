require 'shellutils/shell_argument_exception'
require 'shellutils/shell_wrapper'
require 'flote/runner'
require 'record/session_id_generator'
require 'record/state_recorder'
require 'state_reader'
require 'console_view'
require 'commands/help_command'
require 'commands/xhelp_command'
require 'commands/generate_command'
require 'commands/init_session_command'
require 'commands/capture_single_run_command'
require 'commands/revert_to_green_command'
require 'commands/upload_command'
require 'commands/upload_no_open_command'
require 'commands/upload_zipped_session_command'
require 'commands/start_command'

class CommandConfiguration
	
	attr_reader :commands
	
	def initialize shell, view, scaffolder, hostname
		meta_config_file = MetaConfigFile.new shell
		runner = create_runner shell, view, meta_config_file
		@help_command = HelpCommand.new view
		@xhelp_command = XHelpCommand.new view
		@generate_command = GenerateCommand.new shell, view, scaffolder
		@upload_command = UploadCommand.new shell, view, hostname
		@upload_no_open_command = UploadNoOpenCommand.new @upload_command
		@upload_zipped_session_command = UploadZippedSessionCommand.new shell, view, hostname
		@init_session_command = InitSessionCommand.new view, runner
		@capture_single_run_command = CaptureSingleRunCommand.new shell, view, runner
		@revert_to_green_command = RevertToGreenCommand.new shell, view, meta_config_file, StateReader.new(shell)
		@start_command = StartCommand.new meta_config_file, runner, view, [@upload_command, @revert_to_green_command]
		@commands = [@help_command, @xhelp_command, @generate_command, @init_session_command, 
			@capture_single_run_command, @start_command, @revert_to_green_command,
			@upload_command, @upload_no_open_command, @upload_zipped_session_command]
	end
	
private
	
	def create_runner shell, view, meta_config_file
		state_recorder = StateRecorder.new shell, SessionIdGenerator.new, meta_config_file
		runner = Runner.new shell, view
		runner.init_session_callback = Proc.new {state_recorder.init_session}
		runner.execute_callback = Proc.new {|files, process| state_recorder.record_state files, process}
		runner
	end
	
end

