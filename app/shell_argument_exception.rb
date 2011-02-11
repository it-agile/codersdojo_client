class ShellArgumentException < Exception
	
	attr_accessor :command
	
	def initialize command
		@command = command
	end
	
end
