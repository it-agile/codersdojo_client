#!/usr/bin/env ruby

require "tempfile"
require "rexml/document"
require 'rest_client'

class Scheduler

  def initialize runner
    @runner = runner
  end

  def start
    @runner.start
    while true do
      sleep 1
      @runner.execute
    end
  end

end

class Runner

  attr_accessor :file, :run_command

  def initialize shell, session_provider
    @filename_formatter = FilenameFormatter.new
    @shell = shell
    @session_provider = session_provider
  end

  def start
    init_session
    execute
  end

  def init_session
    @step = 0
    @session_id = @session_provider.generate_id
    @shell.mkdir_p(@filename_formatter.session_dir @session_id)
  end

  def execute
    change_time = @shell.ctime @file
    if change_time == @previous_change_time then
      return
    end
    result = @shell.execute "#{@run_command} #{@file}"
    state_dir = @filename_formatter.state_dir @session_id, @step
    @shell.mkdir state_dir
    @shell.cp @file, state_dir
    @shell.write_file @filename_formatter.result_file(state_dir), result
    @step += 1
    @previous_change_time = change_time
  end

end

class Shell

  MAX_STDOUT_LENGTH = 100000

  def cp source, destination
    FileUtils.cp source, destination
  end

  def mkdir dir
    FileUtils.mkdir dir
  end

  def mkdir_p dirs
    FileUtils.mkdir_p dirs
  end

  def execute command
    spec_pipe = IO.popen(command, "r")
    result = spec_pipe.read MAX_STDOUT_LENGTH
    spec_pipe.close
    puts result
    result
  end

  def write_file filename, content
    file = File.new filename, "w"
    file << content
    file.close
  end

  def read_file filename
    file = File.new filename
    content = file.read
    file.close
    content
  end

  def ctime filename
    File.new(filename).ctime
  end

	def make_os_specific text
		text.gsub('%sh%', shell_extension).gsub('%:%', path_separator).gsub('%rm%', remove_command_name)
	end

	def remove_command_name
		windows? ? 'delete' : 'rm'
	end

	def shell_extension
		windows? ? 'cmd' : 'sh'
	end
	
	def path_separator
		windows? ? ';' : ':'
	end
	
	def windows?
		RUBY_PLATFORM.downcase.include? "windows"
	end

end

class SessionIdGenerator

  def generate_id time=Time.new
		year = format_to_length time.year, 4
		month = format_to_length time.month, 2
		day = format_to_length time.day, 2
		hour = format_to_length time.hour, 2
		minute = format_to_length time.min, 2
		second = format_to_length time.sec, 2
    "#{year}-#{month}-#{day}_#{hour}-#{minute}-#{second}"
  end

  def format_to_length value, len
		value.to_s.rjust len,"0"
	end

end

class StateReader

  attr_accessor :session_id, :next_step

  def initialize shell
    @filename_formatter = FilenameFormatter.new
    @shell = shell
    @next_step = 0
  end

  def state_count
	  dummy_dirs_current_and_parent = 2
    Dir.new(@filename_formatter.session_dir @session_id).count - dummy_dirs_current_and_parent
  end

  def enough_states?
    state_count >= states_needed_for_one_move
  end

	def states_needed_for_one_move
		2
	end

  def get_state_dir
    @filename_formatter.state_dir(@session_id, @next_step)
  end

  def has_next_state
    File.exist?(get_state_dir)
  end

  def read_next_state
    state = State.new
    state_dir = get_state_dir
    state.time = @shell.ctime state_dir
    state.code = @shell.read_file @filename_formatter.source_code_file(state_dir)
    state.result = @shell.read_file @filename_formatter.result_file(state_dir)
    @next_step += 1
    state
  end

end

class FilenameFormatter

  CODERSDOJO_WORKSPACE = ".codersdojo"
  RESULT_FILE = "result.txt"
  STATE_DIR_PREFIX = "state_"


  def source_code_file state_dir
    Dir.entries(state_dir).each { |file|
      return state_file state_dir, file unless file =='..' || file == '.' ||file == RESULT_FILE }
  end

  def result_file state_dir
    state_file state_dir, RESULT_FILE
  end

  def state_file state_dir, file
    "#{state_dir}/#{file}"
  end

  def state_dir session_id, step
    session_directory = session_dir session_id
    "#{session_directory}/#{STATE_DIR_PREFIX}#{step}"
  end

  def session_dir session_id
    "#{CODERSDOJO_WORKSPACE}/#{session_id}"
  end

end

class Progress

  def self.write_empty_progress states
    STDOUT.print "#{states} states to upload"
    STDOUT.print "["+" "*states+"]"
    STDOUT.print "\b"*(states+1)
    STDOUT.flush
  end

  def self.next
    STDOUT.print "."
    STDOUT.flush
  end

  def self.end
    STDOUT.puts
  end
end

class Uploader

  def initialize hostname, framework, session_dir, state_reader = StateReader.new(Shell.new)
		@hostname = hostname
	  @framework = framework
    @state_reader = state_reader
    @state_reader.session_id = session_dir.gsub('.codersdojo/', '')
  end

  def upload_kata
    RestClient.post "#{@hostname}#{@@kata_path}", {:framework => @framework}
  end

  def upload_state kata_id
    state = @state_reader.read_next_state
    RestClient.post "#{@hostname}#{@@kata_path}/#{kata_id}#{@@state_path}", {:code => state.code, :result => state.result, :created_at => state.time}
    Progress.next
  end

  def upload_states kata_id
    Progress.write_empty_progress @state_reader.state_count
    while @state_reader.has_next_state
      upload_state kata_id
    end
    Progress.end
  end

  def upload_kata_and_states
    kata = upload_kata
    upload_states(XMLElementExtractor.extract('kata/id', kata))
    "This is the link to review and comment your kata #{XMLElementExtractor.extract('kata/short-url', kata)}"
  end

  def upload
    return upload_kata_and_states if @state_reader.enough_states?
    return "You need at least two states"
  end

  private
  @@kata_path = '/katas'
  @@state_path = '/states'

end

class XMLElementExtractor
  def self.extract element, xml_string
    doc = REXML::Document.new xml_string
    return doc.elements.each(element) do |found|
      return found.text
    end
  end
end

class State

  attr_accessor :time, :code, :result

  def initialize time=nil, code=nil, result=nil
    @time = time
    @code = code
    @result = result
  end

end

class ArgumentParser
	
	def initialize controller
		@controller = controller
	end
	
	def parse params
		command = params[0] ? params[0] : ""
		if command.downcase == "help" then
			@controller.help params[1]
		elsif command.downcase == "setup" then
			@controller.generate params[1], params[2] ? params[2] : '<kata_file>'
		elsif command.downcase == "upload" then
			@controller.upload params[1], params[2]
		elsif command.downcase == "start" then
			run_command = expand_run_command params[1]
			@controller.start run_command, params[2]
		elsif command.downcase == "spec" then
			# 'spec" is for testing purpose only: do nothing special
		else
			raise ArgumentError
		end
	end

	def expand_run_command command
		if command.end_with?(".sh") then
			"bash #{command}"
		elsif command.end_with?(".bat") or command.end_with?(".cmd") then
			"start #{command}"
		else
			command
		end
	end
	
end

class Controller

	def initialize view, hostname
		@view = view
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
		generator = GeneratorFactory.new.create_generator framework
		shell = Shell.new
		generator_text = generator.generate kata_file
		generator_text = shell.make_os_specific generator_text
		puts generator_text
	end

	def start command, file
		if not command or not file then
			@view.show_missing_command_argument_error "start"
			return
		end
	  @view.show_start_kata command, file
	  dojo = Runner.new Shell.new, SessionIdGenerator.new
	  dojo.file = file
	  dojo.run_command = command
	  scheduler = Scheduler.new dojo
	  scheduler.start
	end

	def upload framework, session_directory
		@view.show_upload_start @hostname
		if session_directory then
		  uploader = Uploader.new @hostname, framework, session_directory
		  p uploader.upload
		else
			@view.show_missing_command_argument_error "upload"
		end
	end

end


class ConsoleView
	
	@@VERSION = '0.9'
	
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
			puts <<-helptext
setup <framework> <kata_file_no_ext>  Setup the environment for the kata for the given framework and kata file.
                                      The kata_file should not have an extension. Use 'prime' and not 'prime.java'.
                                      By now <framework> is one of clojure.is-test, java.junit, javascript.jspec, 
                                      python.unittest, ruby.test/unit.
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
		puts <<-helptext
upload <framework> <session_directory>  Upload the kata written with <framework> in <session_directory> to codersdojo.com. 
                                        <session_directory> is relative to the working directory.
                                        Take a look at the generate command for the supported frameworks.
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

class GeneratorFactory
		
	def initialize
		@frameworks = {"clojure.is-test" => ClosureGenerator,
									 "java.junit" => JavaGenerator, 
								   "javascript.jspec" => JavascriptGenerator,
									 "python.unittest" => PythonGenerator,
									 "ruby.test/unit" => RubyGenerator}	
	end
	
	def create_generator framework
		generator_class = @frameworks[framework]
		if generator_class.nil? then
			generator_class = AnyGenerator
		end
		generator_class.new
	end
	
end

class AnyGenerator
	
	def generate kata_file
<<-generate_help
You have to create two shell scripts manually:
  Create a shell script run-once.%sh% that runs the tests of your kata once.

  Create a second shell script run-endless.sh with this content:
    #{$0} start run-once.%sh% #{kata_file}.<extension>

Run run-endless.%sh% and start your kata.

Assumptions:
  - The whole kata source code is in the one #{kata_file}.<extension>.
generate_help
	end
end

class ClosureGenerator
	def generate kata_file
<<-generate_help
You have to create two shell scripts manually:
  Create a shell script run-once.%sh% with this content:
    java -cp clojure-contrib.jar%:%clojure.jar clojure.main #{kata_file}.clj

  Create a second shell script run-endless.sh with this content:
    #{$0} start run-once.%sh% #{kata_file}.clj

Run run-endless.%sh% and start your kata.

Assumptions:
  - Java is installed on your system and 'java' is in the path.
  - clojure.jar and clojure-contrib.jar are placed in your work directory.
generate_help
	end
end

class JavaGenerator
	def generate kata_file
<<-generate_help
You have to create two shell scripts manually:
  Create a shell script run-once.%sh% with this content:
    %rm% bin/#{kata_file}.class
    javac -cp lib/junit.jar -d bin #{kata_file}.java
    java -cp lib/junit.jar%:%bin #{kata_file}

  Create a second shell script run-endless.sh with this content:
    #{$0} start run-once.%sh% src/#{kata_file}.java

Run run-endless.%sh% and start your kata.

Assumptions:
  - A Java JDK is installed on your system and 'java' and 'javac' are in the path.
  - junit.jar is placed in a directory named 'lib'.
  - The kata source file is placed in the 'src' directory.
  - The kata class file is generated into the 'class' directory.
  - In the source file the classes are placed in the default package.
  - The kata source file has a main method that starts the tests.
  - If your IDE (like Eclipse) compiles the source file, you should remove the first two lines
    in the run-once.%sh% file.
generate_help
	end
end


class JavascriptGenerator
	def generate kata_file
<<-generate_help
You have to create two shell scripts manually:
  Create a shell script run-once.%sh% with this content:
    jspec --rhino run

  Create a second shell script run-endless.sh with this content:
    #{$0} start run-once.%sh% #{kata_file}.js

Run run-endless.%sh% and start your kata.
generate_help
	end
end


class PythonGenerator
	def generate kata_file
<<-generate_help
You have to create two shell scripts manually:
  Create a shell script run-once.%sh% with this content:
    python #{kata_file}.py

  Create a second shell script run-endless.sh with this content:
    #{$0} start run-once.%sh% #{kata_file}.py

Run run-endless.%sh% and start your kata.
generate_help
	end
end


class RubyGenerator
	def generate kata_file
<<-generate_help
You have to create one shell script manually:
  Create a shell script run-endless.%sh% with this content:
    #{$0} start ruby #{kata_file}.rb

Run run-endless.%sh% and start your kata.
generate_help
	end
end

def called_from_spec args
  args[0] == "spec"
end

# entry from shell
if not called_from_spec(ARGV) then
	view = ConsoleView.new
	hostname = "http://www.codersdojo.com"
#	hostname = "http://localhost:3000"
	controller = Controller.new view, hostname
	begin
		arg_parser = ArgumentParser.new controller
		command = arg_parser.parse ARGV
	rescue ArgumentError
		controller.help
	end
end
