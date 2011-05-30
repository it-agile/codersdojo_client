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

	def source_file_in_state_dir? file
		file = extract_last_path_item file
		file != '..' and file != '.' and file != INFO_FILE and file != RESULT_FILE
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

	def step_number_from_state_dir state_dir
		state_dir.delete(STATE_DIR_PREFIX).to_i
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
	  last_separated_by_slash = dir_path.split('/').last
	  last_separated_by_native = dir_path.split(ShellWrapper.new.dir_separator).last
	  last = [last_separated_by_slash, last_separated_by_native].min_by {|item| item.nil? ? 0 : item.size}
		nil_to_empty_string last
	end
	
	private
	
	def nil_to_empty_string object
		object.nil? ? "" : object
	end

end

