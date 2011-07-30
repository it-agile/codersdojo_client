require 'shell_wrapper'

class FilenameFormatter

  CODERSDOJO_WORKSPACE = ".codersdojo"
  RESULT_FILE = "result.txt"
  INFO_FILE = "info.yml"
  STATE_DIR_PREFIX = "state_"
	DIR_SEPARATOR = '/'

	def self.state_dir_prefix
		STATE_DIR_PREFIX
	end

	def self.codersdojo_workspace
		CODERSDOJO_WORKSPACE
	end

	def source_file_in_state_dir? file
		file = Filename.new(file).extract_last_path_item.to_s
		file != '..' and file != '.' and file != INFO_FILE and file != RESULT_FILE
	end

  def result_file state_dir
    state_file state_dir, RESULT_FILE
  end

  def info_file state_dir
    state_file state_dir, INFO_FILE
  end

  def state_file state_dir, file
    concat_path state_dir, file
  end

  def state_dir session_id, step
    session_directory = session_dir session_id
    concat_path session_directory, "#{STATE_DIR_PREFIX}#{step}"
  end

	def step_number_from_state_dir state_dir
		state_dir.delete(STATE_DIR_PREFIX).to_i
	end

  def session_dir session_id
    concat_path CODERSDOJO_WORKSPACE, session_id
  end

	def concat_path path, item
		separator = path.end_with?(DIR_SEPARATOR) ? '' : DIR_SEPARATOR
		"#{path}#{separator}#{item}"
	end
	
end

