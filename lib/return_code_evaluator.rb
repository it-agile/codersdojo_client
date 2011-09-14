class ReturnCodeEvaluator 

  SUCCESS_RETURN_CODE = 0
  FAILURE_RETURN_CODE = 1

  def initialize success_detection
	  @success_detection = success_detection
  end

  def return_code process
	  return process.return_code unless @success_detection
	  return_code_from_output process.output
	end	
	
	def return_code_from_output output
		space_or_start_of_line = "( |^)"
    if output =~ /#{space_or_start_of_line}#{@success_detection}/ then
		  SUCCESS_RETURN_CODE
		else
			FAILURE_RETURN_CODE
		end
	end
	
end
