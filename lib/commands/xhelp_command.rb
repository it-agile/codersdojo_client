class XHelpCommand

  def initialize view
    @view = view
  end

  def execute_from_shell params
    help params[1]
  end

  def help command=nil
    if command then
      @view.show_detailed_help command.downcase
    else
      @view.show_extended_help
    end
  end

  def accepts_shell_command? command
    command == 'xhelp'
  end

end
