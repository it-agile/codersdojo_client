require 'scheduler'
require 'uploader'
require 'filename_formatter'
require 'upload_command'

class Controller

	attr_accessor :uploader
	
	def initialize shell, view, scaffolder, hostname
		@property_filename = '.meta'
		@shell = shell
		@view = view
		@scaffolder = scaffolder
		@hostname = hostname
		@filename_formatter = FilenameFormatter.new
		@uploader = Uploader.new(hostname, '', '')
	end

	def help command=nil
		if command then
			@view.show_detailed_help command.downcase
		else
			@view.show_help
		end
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

	def start command, file
		if not command or not file then
			@view.show_missing_command_argument_error "start"
			return
		end
	  @view.show_start_kata command, file, framework_property
	  dojo = Runner.new @shell, SessionIdGenerator.new
	  dojo.file = file
	  dojo.run_command = command
	  scheduler = Scheduler.new dojo, @view
	  scheduler.start
		if scheduler.last_action_was_upload? then
			upload nil
		end
	end

	# merge with 'upload_with_framework' when the framework parameter is removed
	def upload session_directory, open_browser=true
		upload_with_framework framework_property, session_directory, open_browser
	end

	# framework parameter is obsolete since client version 1.1.08 (08-feb-2011)
	# it stays here for compatibility reasons and will be removed in the near future
	def upload_with_framework framework, session_directory , open_browser=true
		upload_command = UploadCommand.new @shell, @view, @hostname
		upload_command.upload
	end

	def framework_property
		properties['framework']
	end

	def properties
	  @shell.read_properties @property_filename
	end

end

