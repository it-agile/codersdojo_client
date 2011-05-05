require 'session_id_generator'
require 'runner'
require 'shell_argument_exception'
require 'shell_wrapper'
require 'console_view'
require 'help_command'
require 'generate_command'
require 'upload_command'
require 'upload_no_open_command'
require 'start_command'

class ArgumentParser
	
	def initialize shell, view, scaffolder, hostname
		@help_command = HelpCommand.new view
		@upload_command = UploadCommand.new shell, view, hostname
		@upload_no_open_command = UploadNoOpenCommand.new @upload_command
		@generate_command = GenerateCommand.new shell, view, scaffolder
		@start_command = StartCommand.new shell, view, @upload_command
		@commands = [@help_command, @generate_command, @start_command, @upload_command, @upload_no_open_command]
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

