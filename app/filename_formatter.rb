class FilenameFormatter

  CODERSDOJO_WORKSPACE = ".codersdojo"
  RESULT_FILE = "result.txt"
  INFO_FILE = "info.yml"
  STATE_DIR_PREFIX = "state_"

	def self.state_dir_prefix
		STATE_DIR_PREFIX
	end

	def self.codersdojo_workspace
		CODERSDOJO_WORKSPACE
	end

  def source_code_file state_dir
    Dir.entries(state_dir).each { |file|
      return state_file state_dir, file unless file =='..' || file == '.' || file == INFO_FILE || file == RESULT_FILE }
  end

  def result_file state_dir
    state_file state_dir, RESULT_FILE
  end

  def info_file state_dir
    state_file state_dir, INFO_FILE
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

	def without_extension filename
		if filename.include? '.' then
			filename.split('.')[0..-2].join('.')
		else
			filename
		end
	end

  def extract_last_path_item dir_path
	  last = dir_path.split(ShellWrapper.new.dir_separator).last
		last.nil? ? "" : last
	end

end

