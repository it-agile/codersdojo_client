class PersonalCodersDojo
	
	CODERSDOJO_WORKSPACE = ".codersdojo"

  attr_accessor :file
	
	def initialize shell, session_provider
		@shell = shell
		@session_provider = session_provider
		@run_command = "ruby"
	end
	
	def start
		id = @session_provider.generate_id
		@session_dir = "#{CODERSDOJO_WORKSPACE}/#{id}"
		@shell.mkdir_p @session_dir
		@shell.execute "#{@run_command} #{@file}"
		state_dir = "#{@session_dir}/state_0"
		@shell.mkdir state_dir
		@shell.cp @file, state_dir
	end
	
end
