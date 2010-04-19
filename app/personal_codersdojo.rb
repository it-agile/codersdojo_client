require "tempfile"

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

class PersonalCodersDojo
	
	CODERSDOJO_WORKSPACE = ".codersdojo"
	RESULT_FILE = "result.txt"

  attr_accessor :file, :run_command
	
	def initialize shell, session_provider
		@shell = shell
		@session_provider = session_provider
	end
	
	def start
		init_session
		execute
	end
	
	def init_session
		@step = 0
		id = @session_provider.generate_id
		@session_dir = "#{CODERSDOJO_WORKSPACE}/#{id}"
		@shell.mkdir_p @session_dir
	end
	
	def execute
		change_time = @shell.ctime @file
		if change_time == @previous_change_time then return end
		result = @shell.execute "#{@run_command} #{@file}"
		state_dir = "#{@session_dir}/state_#{@step}"
		@shell.mkdir state_dir
		@shell.cp @file, state_dir
		@shell.write_file "#{state_dir}/#{RESULT_FILE}", result
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
	
	def ctime filename
		File.new(filename).ctime
	end
	
end

class SessionIdGenerator
	
	def generate_id
		Time.new.to_i.to_s
	end
	
end

def run_from_shell
	file = ARGV[1]
	puts "Starting PersonalCodersDojo with kata file #{file} ..."
	dojo = PersonalCodersDojo.new Shell.new, SessionIdGenerator.new
	dojo.file = file
	dojo.run_command = "ruby"
	scheduler = Scheduler.new dojo
	scheduler.start
end

def print_help
	puts <<-helptext
PersonalCodersDojo automatically runs your specs/tests of a code kata.
Usage: ruby personal_codersdojo.rb command kata_file
Commands:
 start \t Start the spec/test runner.
 help, -h, --help \t Print this help text.

Examples:
 ruby personal_codersdojo.rb run prime.rb
Run the tests of prime.rb. The test runs automatically every second if prime.rb was modified.

helptext
end

if ARGV[0] == "start" then
	run_from_shell
elsif ["help", "--help", "-h"].include? ARGV[0] then
	print_help
end

