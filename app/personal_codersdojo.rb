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
		result = @shell.execute "#{@run_command} #{@file}"
		state_dir = "#{@session_dir}/state_#{@step}"
		@shell.mkdir state_dir
		@shell.cp @file, state_dir
		@shell.write_file "#{state_dir}/#{RESULT_FILE}", result
		@step += 1
	end
	
end
