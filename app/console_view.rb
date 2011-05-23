require 'shell_wrapper'
require 'text_template_machine'
require 'property_file_missing_exception'

class ConsoleView

	FRAMEWORK_LIST_INDENTATION = 6
	
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
  xhelp                                Print help text for advanced commands.
  setup <framework> <kata_file>        Setup the environment for running the kata.
  upload [<session_dir>]               Upload the kata to http://www.codersdojo.org and open the kata in a browser.
  upload-no-open [<session_dir>]       Upload the kata to http://www.codersdojo.org

Report bugs to <codersdojo@it-agile.de>
helptext
	end
	
	def show_extended_help
		show <<-helptext
Usage: #{current_command_path} command [options]
Commands:
  help <command>                                    See the details of the command.
  init-session                                      Create a new session dir within the .codersdojo dir.
  capture-single-run <shell_command> <kata_file>    Capture a single run.
  start <shell_command> <kata_file>                 Start the continuous test loop.
helptext
  end

	def show_detailed_help command
		command = command.gsub('-', '_')
		begin
			eval "show_help_#{command}"
		rescue
			show_help_unknown command
		end
	end

	def show_help_setup
			templates = @scaffolder.list_templates_as_dotted_list FRAMEWORK_LIST_INDENTATION
			show <<-helptext
			
setup <framework> <kata_file>  
    Setup the environment for the kata for the given framework and kata file.
    The <kata_file> is the one file that will contain the source code of the code kata.
    If <kata_file> does not have an extension it will be added automatically 
    - except if <framework> is ??? (see below).
    By now <framework> is one of these:
#{templates}
    Use ??? as framework if your framework isn't in the list.

Example:
    :%/%dojo%/%my_kata$ #{current_command_path} setup ruby.test-unit prime
        Setup the the environment for executing a code kata in kata file 'prime' with Ruby and test/unit.
helptext
	end

	def show_help_start
		show <<-helptext
		
start <shell_command> <kata_file>  
    Start the continuous test runner, that runs <shell_command> whenever <kata_file>
    changes. The <kata_file> has to include the whole source code of the kata.
    Whenever the test runner is started, it creates a new session directory in the 
    directory .codersdojo where it logs the steps of the kata.
helptext
	end

	def show_help_upload
		show <<-helptext
		
upload                      
    Upload the newest kata session in .codersdojo to codersdojo.com.
    After the kata is uploaded the browser is started with the URL of the uploaded kata.

upload <session_directory>  
    Upload the kata <session_directory> to codersdojo.com. 
    <session_directory> is relative to the working directory.

Examples:
    :%/%dojo%/%my_kata$ #{current_command_path} upload
        Upload the newest kata located in directory ".codersdojo" to codersdojo.com.
    :%/%dojo%/%my_kata$ #{current_command_path} upload .codersdojo%/%2010-11-02_16-21-53
        Upload the kata located in directory ".codersdojo%/%2010-11-02_16-21-53" to codersdojo.com.
helptext
	end
	
	def show_help_init_session
		show <<-helptext

init-session
    Create a new session dir in the .codersdojo dir.
    Usually this command is used before using capture-single-run.
helptext
	end
	
	def show_help_capture_single_run
		show <<-helptext
		
capture-single-run <shell_command> <kata_file>  
    Execute <shell-command> once for <kata_file>.
    The <kata_file> has to include the whole source code of the kata.
    The run will be captured into the newest session dir in the .codersdojo dir.
    Usually this command is used after a session dir has been created with the init-session command.
helptext
	end
	
	def show_help_upload_no_open
		show <<-helptext

upload-no-open                      
    Upload the newest kata session in .codersdojo to codersdojo.com.

upload-no-opem <session_directory>  
    Upload the kata <session_directory> to codersdojo.com. 
    <session_directory> is relative to the working directory.

Examples:
    :%/%dojo%/%my_kata$ #{current_command_path} upload-no-open
        Upload the newest kata located in directory ".codersdojo" to codersdojo.com.
    :%/%dojo%/%my_kata$ #{current_command_path} upload-no-open .codersdojo%/%2010-11-02_16-21-53
        Upload the kata located in directory ".codersdojo%/%2010-11-02_16-21-53" to codersdojo.com.
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
		show_detailed_help command
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
		show "You finished your kata. You can upload it with 'codersdojo upload'."
	end
	
	def show_init_session_result session_dir
		show "Session directory created: #{session_dir}"
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
