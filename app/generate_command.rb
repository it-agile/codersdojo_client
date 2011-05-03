class GenerateCommand
	
	def initialize shell, view, scaffolder
		@shell = shell
		@view = view
		@scaffolder = scaffolder
	end
	
	def execute_from_shell params
		generate params[1], params[2]
	end
	
	def generate framework, kata_file
		if not kata_file then
			@view.show_missing_command_argument_error "setup", "kata_file"
			return
		end
		begin
			@scaffolder.scaffold framework, kata_file
			@view.show "\n" + @shell.read_file("README")
		rescue
			@view.show_unknown_framework_error framework, @scaffolder.list_templates
		end		
	end
	
	def accepts_shell_command? command
		command == 'setup'
	end

end