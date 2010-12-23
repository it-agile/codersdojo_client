class FilenameFormatter

  CODERSDOJO_WORKSPACE = ".codersdojo"
  RESULT_FILE = "result.txt"
  STATE_DIR_PREFIX = "state_"

	def self.state_dir_prefix
		STATE_DIR_PREFIX
	end

  def source_code_file state_dir
    Dir.entries(state_dir).each { |file|
      return state_file state_dir, file unless file =='..' || file == '.' ||file == RESULT_FILE }
  end

  def result_file state_dir
    state_file state_dir, RESULT_FILE
  end

  def state_file state_dir, file
    "#{state_dir}/#{file}"
  end

  def state_dir session_id, step
    session_directory = session_dir session_id
    "#{session_directory}/#{STATE_DIR_PREFIX}#{step}"
  end

  def session_dir session_id
    "#{CODERSDOJO_WORKSPACE}/#{session_id}"
  end

end

