require 'scheduler'
require 'uploader'

class Controller

	def initialize shell, view, scaffolder, hostname
		@shell = shell
		@view = view
		@scaffolder = scaffolder
		@hostname = hostname
	end

	def help command=nil
		if command then
			@view.show_detailed_help command.downcase
		else
			@view.show_help
		end
	end

	def generate framework, kata_file
		begin
			@scaffolder.scaffold framework, kata_file
		  puts "\n" + @shell.read_file("README")
		rescue
			puts "Unkown framework #{framework}. Possible frameworks:"
			puts @scaffolder.list_templates
		end		
	end

	def start command, file
		if not command or not file then
			@view.show_missing_command_argument_error "start"
			return
		end
	  @view.show_start_kata command, file
	  dojo = Runner.new ShellWrapper.new, SessionIdGenerator.new
	  dojo.file = file
	  dojo.run_command = command
	  scheduler = Scheduler.new dojo
	  scheduler.start
	end

	def upload framework, session_directory
		@view.show_upload_start @hostname
		if session_directory then
		  uploader = Uploader.new @hostname, framework, session_directory
		  @view.show_upload_result uploader.upload
		else
			@view.show_missing_command_argument_error "upload"
		end
	end

end

