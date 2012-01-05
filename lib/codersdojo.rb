#!/usr/bin/env ruby

require 'shellutils/argument_parser'
require 'console_view'
require 'commands/command_configuration'
require 'scaffold/scaffolder'
require 'rest_client'

class CodersDojo
	
	def initialize params, hostname = "http://www.codersdojo.com"
		@params = params
		@hostname = hostname
	end

  def handle_internal_server_error view, exception
	  log_file_name = 'error.log'
	  File.open(log_file_name, 'w') do |f|  
		  f.puts "### Error ###"
      f.puts exception.message 
      f.puts
      f.puts "### Client backtrace ###"
			f.puts exception.backtrace
      f.puts
      f.puts "### HTTP Body ###"			
      f.puts exception.http_body
    end  
		view.show_internal_server_error exception, log_file_name
	end
	
	def run
		if called_from_spec? then return end
		shell = ShellWrapper.new
		scaffolder = Scaffolder.new shell
		view = ConsoleView.new scaffolder

		begin
			command_config = CommandConfiguration.new shell, view, scaffolder, @hostname
			arg_parser = ArgumentParser.new command_config.commands
			command = arg_parser.parse @params
		rescue ShellArgumentException => e
			view.show_unknwon_command_message e.command
		rescue PropertyFileMissingException => e
			view.show_properties_file_missing_error e.filename
		rescue RestClient::InternalServerError => e
			handle_internal_server_error view, e
		end
  end

	def called_from_spec?
	  @params and @params[0] == "spec"
	end
	
end
