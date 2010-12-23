require 'shell_wrapper'

class ConsoleView
	
	@@VERSION = '0.9'
	
	def initialize scaffolder
		@scaffolder = scaffolder
	end
	
	def show_help
		puts <<-helptext
Personal CodersDojo, Version #{@@VERSION}, http://www.codersdojo.com, Copyright by it-agile GmbH (http://www.it-agile.de)
PersonalCodersDojo automatically runs your tests of a code kata.

helptext
		show_usage
	end
	
	def show_usage
		puts <<-helptext
Usage: #{$0} command [options]
Commands:
  help, -h, --help                   Print this help text.
  help <command>                     See the details of the command.
  setup <framework> <kata_file>      Setup the environment for running the kata.
  upload <framework> <session_dir>   Upload the kata to http://www.codersdojo.org

Report bugs to <codersdojo@it-agile.de>
helptext
	end

	def show_detailed_help command
		if command == 'setup' then
			show_help_setup
		elsif command == 'start' then
			show_help_start
		elsif command == 'upload' then
			show_help_upload
		else
			show_help_unknown command
		end
	end

	def show_help_setup
			templates = @scaffolder.list_templates
			puts <<-helptext
			
setup <framework> <kata_file_no_ext>  Setup the environment for the kata for the given framework and kata file.
                                      The kata_file should not have an extension. Use 'prime' and not 'prime.java'.
                                      By now <framework> is one of #{templates}.
                                      Use ??? as framework if your framework isn't in the list.

Example:
    :/dojo/my_kata% #{$0} setup ruby.test/unit prime
        Show the instructions how to setup the environment for kata execution with Ruby and test/unit.
helptext
	end

	def show_help_start
		puts <<-helptext
		
start <shell_command> <kata_file>  Start the continuous test runner, that runs <shell-command> whenever <kata_file>
                                   changes. The <kata_file> has to include the whole source code of the kata.
                                   Whenever the test runner is started, it creates a new session directory in the 
                                   directory .codersdojo where it logs the steps of the kata.
helptext
	end

	def show_help_upload
		templates = @scaffolder.list_templates
		puts <<-helptext
		
upload <framework> <session_directory>  Upload the kata written with <framework> in <session_directory> to codersdojo.com. 
                                        <session_directory> is relative to the working directory.
                                        By now <framework> is one of #{templates}.
                                        If you used another framework, use ??? and send an email to codersdojo@it-agile.de

Example:
    :/dojo/my_kata$ #{$0} upload ruby.test/unit .codersdojo/2010-11-02_16-21-53
        Upload the kata (written in Ruby with the test/unit framework) located in directory ".codersdojo/2010-11-02_16-21-53" to codersdojo.com.
helptext
	end
	
	def show_help_unknown command
		puts <<-helptext
Command #{command} not known. Try '#{$0} help' to list the supported commands.
helptext
	end
	
	def show_start_kata command, file
	  puts "Starting PersonalCodersDojo with command #{command} and kata file #{file}. Use Ctrl+C to finish the kata."		
	end
	
	def show_missing_command_argument_error command
		puts "Command <#{command}> recognized but no argument was provided (at least one argument is required).\n\n"
		show_usage
	end
	
	def show_upload_start hostname
		puts "Start upload to #{hostname}"
	end
	
	def show_upload_result result
		puts result
	end
	
	def show_socket_error command
		puts "Encountered network error while <#{command}>. Is http://www.codersdojo.com down?"
	end
	
end
