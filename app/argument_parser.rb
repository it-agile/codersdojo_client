require 'session_id_generator'
require 'runner'
require 'shell_argument_exception'

class ArgumentParser
	
	def initialize controller
		@controller = controller
	end
	
	def parse params		
		command = params[0] ? params[0].downcase : "help"
		if command == "help" then
			@controller.help params[1]
		elsif command == "setup" then
			@controller.generate params[1], params[2]
		elsif command == "upload" then
			@controller.upload params[1]
		elsif command == "upload-no-open" then
			@controller.upload params[1], false
		elsif command == "upload-with-framework" then
			@controller.upload_with_framework params[1], params[2]
		elsif command == "start" then
			run_command = expand_run_command params[1]
			@controller.start run_command, params[2]
		elsif command == "spec" then
			# 'spec" is for testing purpose only: do nothing special
		else
			raise ShellArgumentException.new command
		end
	end

	def expand_run_command command
		if command.end_with?(".sh") then
			"bash #{command}"
		else
			command
		end
	end
	
end

