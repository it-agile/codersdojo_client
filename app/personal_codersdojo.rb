require "rubygems"
require "tempfile"
require "rexml/document"

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
    Dir.new(@filename_formatter.session_dir @session_id).count - 2
  end

  def enough_states?
    state_count >= 2
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

  def self.wirite_empty_progress states
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

  def initialize hostname, session_dir, state_reader = StateReader.new(Shell.new)
    @state_reader = state_reader
    @state_reader.session_id = session_dir.gsub('.codersdojo/', '')
		@hostname = hostname
  end

  def upload_kata
    RestClient.post "#{@hostname}#{@@kata_path}", []
  end

  def upload_state kata_id
    state = @state_reader.read_next_state
    RestClient.post "#{@hostname}#{@@kata_path}/#{kata_id}#{@@state_path}", {:code => state.code, :created_at => state.time}
    Progress.next
  end

  def upload_states kata_id
     Progress.wirite_empty_progress @state_reader.state_count
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
    begin
      require 'rest_client'
    rescue LoadError
      return 'Cant find gem rest-client. Please install it.'
    end
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
			@controller.help
		elsif command.downcase == "upload" then
			@controller.upload params[1]
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

	def help
		@view.show_help
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

	def upload session_directory
		if session_directory then
		  uploader = Uploader.new hostname, session_directory
		  p uploader.upload
		else
			@view.show_missing_command_argument_error "upload"
		end
	end

end


class ConsoleView
	
	def show_help
		puts "PersonalCodersDojo automatically runs your specs/tests of a code kata."
		show_usage
	end
	
	def show_usage
		puts <<-helptext
Usage: ruby personal_codersdojo.rb command [options]
Commands:
  start <shell-command> <kata_file> \t\t Start the spec/test runner.
  upload <session_directory> \t Upload the kata in <session_directory> to codersdojo.com. <session_directory> is relative to the working directory.
  help, -h, --help \t\t Print this help text.

Examples:
    :/dojo/my_kata$ ruby ../app/personal_codersdojo.rb start ruby prime.rb
      Run the tests of prime.rb. The test runs automatically every second if prime.rb was modified.

    :/dojo/my_kata$ ruby ../app/personal_codersdojo.rb upload  ../sandbox/.codersdojo/1271665711
      Upload the kata located in directory ".codersdojo/1271665711" to codersdojo.com.
helptext
	end
	
	def show_start_kata command, file
	  puts "Starting PersonalCodersDojo with command #{command} and kata file #{file}. Use Ctrl+C to finish the kata."		
	end
	
	def show_missing_command_argument_error command
		puts "Command <#{command}> recognized but no argument was provided (at least one argument is required).\n\n"
		show_usage
	end
	
	def show_upload_result result
		puts result
	end
	
	def show_socket_error command
		puts "Encountered network error while <#{command}>. Is http://www.codersdojo.com down?"
	end
	
end

def called_from_spec args
  args[0] == "spec"
end

# entry from shell
if not called_from_spec(ARGV) then
	view = ConsoleView.new
	hostname = "http://www.codersdojo.com"
	# hostname = "http://localhost:3000"
	controller = Controller.new view, hostname
	begin
		arg_parser = ArgumentParser.new controller
		command = arg_parser.parse ARGV
	rescue ArgumentError
		controller.help
	rescue SocketError
		view.show_socket_error ARGV[0]
	end
end
