#!/usr/bin/env ruby

require 'console_view'
require 'controller'
require 'argument_parser'
require 'scaffolder'

class CodersDojo
	
	def initialize params
		@params = params
	end
	
	def run
		if called_from_spec? then return end
		hostname = "http://www.codersdojo.com"
	#	hostname = "http://localhost:3000"

		shell = ShellWrapper.new
		scaffolder = Scaffolder.new shell
		view = ConsoleView.new scaffolder
		controller = Controller.new shell, view, scaffolder, hostname

		begin
			arg_parser = ArgumentParser.new controller
			command = arg_parser.parse @params
		rescue ShellArgumentException
			controller.help
		end
  end

	def called_from_spec?
	  @params and @params[0] == "spec"
	end
	
end

# entry from shell
CodersDojo.new(ARGV).run
