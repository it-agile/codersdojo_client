require 'shell_wrapper'
require 'text_template_machine'
require 'property_file_missing_exception'

class ConsoleView
	
	def initialize scaffolder
		@scaffolder = scaffolder
		@template_machine = TextTemplateMachineFactory.create ShellWrapper.new
	end
	
	def show_help
		show <<-helptext
CodersDojo-Client, http://www.codersdojo.org, Copyright by it-agile GmbH (http://www.it-agile.de)
CodersDojo-Client automatically runs your code kata, logs the progress and uploads the kata to codersdojo.org.

helptext
		show_usage
	end
	
	def show_usage
		show <<-helptext
Usage: #{current_command_path} command [options]
Commands:
  help, -h, --help                     Print this help text.
  help <command>                       See the details of the command.
  setup <framework> <kata_file>        Setup the environment for running the kata.
  upload [<session_dir>]               Upload the kata to http://www.codersdojo.org and open the kata in a browser.
  upload-no-open [<session_dir>]       Upload the kata to http://www.codersdojo.org
  upload-with-framework <framework> [<session_dir>]   
                                       Upload the kata to http://www.codersdojo.org
                                       !!! This command exists for compatibility reasons only.
                                       !!! It will be removed in the near future. 
                                       !!! Please run 'setup' again to generate the .meta file
                                       !!! and use 'upload' without the 'framework' parameter.

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
		elsif command == 'upload-no-open' then
			show_help_upload_no_open
		elsif command == 'upload-with-framework' then
			show_help_upload_with_framework
		else
			show_help_unknown command
		end
	end

	def show_help_setup
			templates = @scaffolder.list_templates
			show <<-helptext
			
setup <framework> <kata_file>  Setup the environment for the kata for the given framework and kata file.
                               By now <framework> is one of #{templates}.
                               Use ??? as framework if your framework isn't in the list.

Example:
    :%/%dojo%/%my_kata$ #{current_command_path} setup ruby.test-unit prime
        Show the instructions how to setup the environment for kata execution with Ruby and test/unit.
helptext
	end

	def show_help_start
		show <<-helptext
		
start <shell_command> <kata_file>  Start the continuous test runner, that runs <shell-command> whenever <kata_file>
                                   changes. The <kata_file> has to include the whole source code of the kata.
                                   Whenever the test runner is started, it creates a new session directory in the 
                                   directory .codersdojo where it logs the steps of the kata.
helptext
	end

	def show_help_upload
		show <<-helptext
		
upload                      Upload the newest kata session in .codersdojo to codersdojo.com.
                            After the kata is uploaded the browser is started with the URL of the uploaded kata.

upload <session_directory>  Upload the kata <session_directory> to codersdojo.com. 
                            <session_directory> is relative to the working directory.

Examples:
    :%/%dojo%/%my_kata$ #{current_command_path} upload
        Upload the newest kata located in directory ".codersdojo" to codersdojo.com.
    :%/%dojo%/%my_kata$ #{current_command_path} upload .codersdojo%/%2010-11-02_16-21-53
        Upload the kata located in directory ".codersdojo%/%2010-11-02_16-21-53" to codersdojo.com.
helptext
	end
	
	def show_help_upload_no_open
		show <<-helptext

upload-no-open                      Upload the newest kata session in .codersdojo to codersdojo.com.

upload-no-opem <session_directory>  Upload the kata <session_directory> to codersdojo.com. 
                                    <session_directory> is relative to the working directory.

Examples:
    :%/%dojo%/%my_kata$ #{current_command_path} upload-no-open
        Upload the newest kata located in directory ".codersdojo" to codersdojo.com.
    :%/%dojo%/%my_kata$ #{current_command_path} upload-no-open .codersdojo%/%2010-11-02_16-21-53
        Upload the kata located in directory ".codersdojo%/%2010-11-02_16-21-53" to codersdojo.com.
helptext
	end

	def show_help_upload_with_framework
		templates = @scaffolder.list_templates
		show <<-helptext

upload-with-framework <framework> [<session_directory>]
                                          Upload the kata written with <framework> in <session_directory> to codersdojo.com. 
                                          <session_directory> is relative to the working directory.
                                          If you don't specify a <session_directory> the newest session in .codersdojo is uploaded.
                                          By now <framework> is one of #{templates}.
                                          If you used another framework, use ??? and send an email to codersdojo@it-agile.de
																					After the kata is uploaded the browser is started with the URL of the uploaded kata.

Example:
    :%/%dojo%/%my_kata$ #{current_command_path} upload-with-framework ruby.test-unit .codersdojo%/%2010-11-02_16-21-53
        Upload the kata (written in Ruby with the test/unit framework) located in directory ".codersdojo%/%2010-11-02_16-21-53" to codersdojo.com.
helptext
	end

	def show_help_unknown command
		show <<-helptext
Command #{command} not known. Try '#{current_command_path} help' to list the supported commands.
helptext
	end
	
	def show_unknwon_command_message command
		show "Command #{command} not known.\n\n"
		show_usage
	end
	
	def show_start_kata command, file, framework
	  show "Starting CodersDojo-Client with command #{command} and kata file #{file} with framework #{framework}. Use Ctrl+C to finish the kata."		
	end
	
	def show_missing_command_argument_error command, missing_argument
		show "Command <#{command}> recognized but argument <#{missing_argument}> was missing.\n"
		eval "show_help_#{command}"
	end
	
	def show_upload_start session_directory, hostname, framework
		show "Start upload from #{session_directory} with framework #{framework} to #{hostname}"
	end
	
	def show_upload_result result
		show result
	end
	
	def show_socket_error command
		show "Encountered network error while <#{command}>. Is http://www.codersdojo.com down?"
	end
	
	def show_unknown_framework_error framework, templates
		show "Unkown framework #{framework}. Possible frameworks:"
		show templates
		show "Use ??? as framework if your framework isn't in the list."
	end
	
	def show_kata_exit_message
		show <<-msg 

You finished your kata. Choose your next action:
  u) Upload the kata to http://www.codersdojo.com.
  e) Exit without uploading.
  r) Resume the kata.
msg
	end

	def show_properties_file_missing_error filename
		show <<-msg
Property file #{filename} is missing.
Maybe you created the directory structure with an older version of CodersDojo?
Recreate the directory structure with the current version with 'codersdojo setup ...'.
msg
	end
		
	def show_kata_upload_hint
		show "You finished your kata. Now upload it with 'codersdojo upload'."
	end
		
	def show text
		puts @template_machine.render(text)
	end

	def read_user_input
		STDIN.gets
	end

	def current_command_path
		$0.gsub '/', '%/%'
	end
	
end
