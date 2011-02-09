class Scheduler

	attr_reader :last_action

  def initialize runner, view
    @runner = runner
		@view = view
		@last_action = ""
  end

  def start
		@last_action = ""
		trap("INT") {
			interrupt_kata
		}
    @runner.start
    while continue? do
      sleep 1
      @runner.execute
    end
  end

	def interrupt_kata
		@view.show_kata_exit_message 
		@last_action = @view.read_user_input.downcase
		if last_action_was_exit? then
			@view.show_kata_upload_hint
		end
	end
	
	def continue?
		@last_action == '' or last_action_was_resume?
	end

	def last_action_was_resume?
		@last_action.start_with? 'r'
	end

	def last_action_was_exit?
		@last_action.start_with? 'e'
	end

	def last_action_was_upload?
		@last_action.start_with? 'u'
	end

end