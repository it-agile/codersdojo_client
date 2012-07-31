class SchedulerInterruptListener

  def initialize view, commands
    @view = view
    @commands = commands
    @continue_after_command = false
    @last_action = ""
  end

  def interrupt
    @continue_after_command = false
    @view.show_kata_exit_message
    @last_action = @view.read_user_input.downcase
    @commands.each do |command|
      if @last_action.start_with? command.command_key
        command.execute
        @continue_after_command = command.continue_test_loop?
      end
    end
    if last_action_was_exit? then
      @view.show_kata_upload_hint
    end
    continue?
  end

  def continue?
    @last_action == '' or last_action_was_resume? or @continue_after_command
  end

  def last_action_was_resume?
    @last_action.start_with? 'r'
  end

  def last_action_was_exit?
    @last_action.start_with? 'e'
  end

end
