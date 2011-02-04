require 'tempfile'

class ShellWrapper

  MAX_STDOUT_LENGTH = 100000

  def cp source, destination
    FileUtils.cp source, destination
  end

  def cp_r source, destination
    FileUtils.cp_r source, destination
  end

  def mkdir dir
    FileUtils.mkdir dir
  end

  def mkdir_p dirs
    FileUtils.mkdir_p dirs
  end

	def rename old_filename, new_filename
		File.rename old_filename, new_filename
	end

	def current_file
		__FILE__
	end

  def execute command
	  redirect_stderr_to_stdout = "2>&1"
    spec_pipe = IO.popen("#{command} #{redirect_stderr_to_stdout}", "r")
    result = spec_pipe.read MAX_STDOUT_LENGTH
    spec_pipe.close
    puts result unless result.nil?
    result
  end

  def write_file filename, content
    file = File.new filename, "w"
    file << content
    file.close
  end

  def read_file filename
    file = File.new filename
    content = file.read
    file.close
    content
  end

  def creation_time filename
    File.ctime(filename)
  end

  def modification_time filename
    File.mtime(filename)
  end

	def real_dir_entries dir
		Dir.new(dir).entries - ["..", "."]
	end
	
	def newest_dir_entry dir
		Dir.new(dir).sort_by do |entry| 
			complete_path = File.join dir, entry
			File.mtime(complete_path)
		end.last
	end

  def file? filename
		File.file? filename
	end
	
	def open_with_default_app filename
		execute "#{open_command_name} #{filename}"
	end
	
	def remove_command_name
		windows? ? 'del' : 'rm'
	end
	
	def open_command_name
		if windows? then
			'start'
		elsif mac? then
			'open'
		else
			'xdg-open'
		end
	end

	def shell_extension
		windows? ? 'cmd' : 'sh'
	end
	
	def path_separator
		windows? ? ';' : ':'
	end
	
	def windows?
		platform = RUBY_PLATFORM.downcase
		platform.include?("windows") or platform.include?("mingw32")
	end

	def mac?
		platform = RUBY_PLATFORM.downcase
		platform.include?("universal-darwin")
	end

end

