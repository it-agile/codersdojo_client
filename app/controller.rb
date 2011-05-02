require 'scheduler'
require 'filename_formatter'
require 'help_command'
require 'generate_command'
require 'start_command'
require 'upload_command'

class Controller

	attr_accessor :uploader
	
	def initialize shell, view, scaffolder, hostname
		@help_command = HelpCommand.new view
		@upload_command = UploadCommand.new shell, view, hostname
		@generate_command = GenerateCommand.new shell, view, scaffolder
		@start_command = StartCommand.new shell, view, @upload_command
	end

	def help command=nil
		@help_command.help command
	end

	def generate framework, kata_file
		@generate_command.generate framework, kata_file
	end

	def start command, file
		@start_command.start command, file
	end

	def upload session_directory, open_browser=true
		upload_with_framework nil, session_directory, open_browser
	end

end

