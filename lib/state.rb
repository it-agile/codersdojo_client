class State

  attr_accessor :time, :files, :result, :return_code, :file_contents

	def green?
		@return_code == 0
	end
	
	def red?
		not green?
	end

end
