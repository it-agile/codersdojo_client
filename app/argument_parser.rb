class ArgumentParser
	
	def initialize controller
		@controller = controller
	end
	
	def parse params
		command = params[0] ? params[0] : ""
		if command.downcase == "help" then
			@controller.help params[1]
		elsif command.downcase == "setup" then
			@controller.generate params[1], params[2] ? params[2] : '<kata_file>'
		elsif command.downcase == "upload" then
			@controller.upload params[1], params[2]
		elsif command.downcase == "start" then
			run_command = expand_run_command params[1]
			@controller.start run_command, params[2]
		elsif command.downcase == "spec" then
			# 'spec" is for testing purpose only: do nothing special
		else
			raise ArgumentError
		end
	end

	def expand_run_command command
		if command.end_with?(".sh") then
			"bash #{command}"
		elsif command.end_with?(".bat") or command.end_with?(".cmd") then
			"start #{command}"
		else
			command
		end
	end
	
end

