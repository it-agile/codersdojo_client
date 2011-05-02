class HelpCommand

	def initialize view
		@view = view
	end
	
	def help command=nil
		if command then
			@view.show_detailed_help command.downcase
		else
			@view.show_help
		end
	end

end
