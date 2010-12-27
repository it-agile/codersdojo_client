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

	def current_file
		__FILE__
	end

  def execute command
    spec_pipe = IO.popen(command, "r")
    result = spec_pipe.read MAX_STDOUT_LENGTH
    spec_pipe.close
    puts result
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

  def ctime filename
    File.new(filename).ctime
  end

	def real_dir_entries dir
		current_and_parent = 2
		Dir.new(dir).entries.drop current_and_parent
	end

	def read_file filename
		generator_text = IO.readlines(filename).to_s;
	end

	def write_file filename, content
		File.open(filename, 'w') do |f|  
		  f.puts content 
		end
	end

	def remove_command_name
		windows? ? 'del' : 'rm'
	end

	def shell_extension
		windows? ? 'cmd' : 'sh'
	end
	
	def path_separator
		windows? ? ';' : ':'
	end
	
	def windows?
		RUBY_PLATFORM.downcase.include? "windows"
	end

end

