class UploadNoOpenCommand

  def initialize upload_command
    @upload_command = upload_command
  end

  def execute_from_shell params
    upload params[1]
  end

  def upload session_directory
    @upload_command.upload session_directory, false
  end

  def accepts_shell_command? command
    command == 'upload-no-open'
  end

  def continue_test_loop?
    false
  end

end
