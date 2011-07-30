require 'runner'

class InitSessionCommand

	def initialize shell, view
		@shell = shell
		@view = view
	end

	def execute_from_shell params
		init_session
	end

	def init_session
		runner = Runner.new @shell, SessionIdGenerator.new, @view
	  session_dir = runner.init_session
	  @view.show_init_session_result session_dir
	end
	
	def accepts_shell_command? command
		command == 'init-session'
	end
	
	def continue_test_loop?
		false
	end
		
end
