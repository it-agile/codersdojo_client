#!/usr/bin/env ruby

require 'console_view'
require 'controller'
require 'argument_parser'
require 'scaffolder'

def called_from_spec args
  args[0] == "spec"
end

# entry from shell
if not called_from_spec(ARGV) then
	hostname = "http://www.codersdojo.com"
#	hostname = "http://localhost:3000"

	shell = ShellWrapper.new
	scaffolder = Scaffolder.new shell
	view = ConsoleView.new scaffolder
	controller = Controller.new shell, view, scaffolder, hostname
	
	begin
		arg_parser = ArgumentParser.new controller
		command = arg_parser.parse ARGV
	rescue ShellArgumentException
		controller.help
	end
end
