require 'info_property_file'
require 'filename'
require 'filename_formatter'
require 'state'

class StateReader

  attr_accessor :session_id, :session_dir, :next_step

  def initialize shell
    @filename_formatter = FilenameFormatter.new
    @shell = shell
		reset
  end

	def reset
		@next_step = 0
	end

	def session_dir= session_dir
		@session_dir = session_dir
		@session_id = Filename.new(@session_dir).extract_last_path_item.to_s
	end

  def state_count
	  @shell.real_dir_entries(@filename_formatter.session_dir @session_id).count
  end

  def enough_states?
    state_count >= states_needed_for_one_move
  end

	def states_needed_for_one_move
		2
	end

  def get_state_dir step=@next_step
    @filename_formatter.state_dir(@session_id, step)
  end

  def has_next_state
		state_exist? @next_step
  end

	def state_exist? step=@next_step
		File.exist?(get_state_dir step)
	end

	def goto_last_state
		step = 0
		while state_exist?(step) do step += 1 end
		@next_step = step-1
	end

	def read_state
		state = State.new
    state_dir = get_state_dir
    state.time = @shell.creation_time state_dir
		state.files = read_source_files state_dir
    state.file_contents = read_source_file_contents state.files
		state.result = @shell.read_file @filename_formatter.result_file(state_dir)
		properties = @shell.read_properties @filename_formatter.info_file(state_dir)
		fill_state_with_properties state, properties
		state
   end

  def read_next_state
	  state = read_state
    @next_step += 1
    state
  end

  def read_previous_state
		state = read_state
		@next_step -= 1
		state
  end

	def read_source_files state_dir
		files = @shell.files_in_dir_tree state_dir
		files.find_all{|file| @filename_formatter.source_file_in_state_dir? file}
	end

	def read_source_file_contents source_files
		marker = "=========="
		source_files.collect {|file| 
			filename = Filename.new(file).extract_last_path_item.to_s
			code = @shell.read_file(file)
			"#{marker} #{filename} #{marker}\n\n#{code}"
		}
	end

	def fill_state_with_properties state, properties
		state.return_code = properties[InfoPropertyFile.RETURN_CODE_PROPERTY]
	end

end

