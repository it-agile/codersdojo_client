class StartCommand
	
	def initialize shell, view, upload_command
		@shell = shell
		@view = view
		@upload_command = upload_command
	end

	def start command, file
		unless command then @view.show_missing_command_argument_error "start", "shell_command"; return end
		unless file then @view.show_missing_command_argument_error "start", "kata_file"; return end
	  @view.show_start_kata command, file, framework_property
	  dojo = Runner.new @shell, SessionIdGenerator.new
	  dojo.file = file
	  dojo.run_command = command
	  scheduler = Scheduler.new dojo, @view, [@upload_command]
	  scheduler.start
	end

end