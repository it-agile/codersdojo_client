#!/usr/bin/env ruby

require 'console_view'
require 'argument_parser'
require 'scaffold/scaffolder'

class CodersDojo
	
	def initialize params, hostname = "http://www.codersdojo.com"
		@params = params
		@hostname = hostname
	end
	
	def run
		if called_from_spec? then return end
		shell = ShellWrapper.new
		scaffolder = Scaffolder.new shell
		view = ConsoleView.new scaffolder

		begin
			arg_parser = ArgumentParser.new shell, view, scaffolder, @hostname
			command = arg_parser.parse @params
		rescue ShellArgumentException => e
			view.show_unknwon_command_message e.command
		rescue PropertyFileMissingException => e
			view.show_properties_file_missing_error e.filename
		end
  end

	def called_from_spec?
	  @params and @params[0] == "spec"
	end
	
end
