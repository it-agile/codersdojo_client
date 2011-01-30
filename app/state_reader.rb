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
		@session_id = @filename_formatter.extract_last_path_item @session_dir
	end

  def state_count
	  dummy_dirs_current_and_parent = 2
    Dir.new(@filename_formatter.session_dir @session_id).count - dummy_dirs_current_and_parent
  end

  def enough_states?
    state_count >= states_needed_for_one_move
  end

	def states_needed_for_one_move
		2
	end

  def get_state_dir
    @filename_formatter.state_dir(@session_id, @next_step)
  end

  def has_next_state
    File.exist?(get_state_dir)
  end

  def read_next_state
    state = State.new
    state_dir = get_state_dir
    state.time = @shell.creation_time state_dir
    state.code = @shell.read_file @filename_formatter.source_code_file(state_dir)
    state.result = @shell.read_file @filename_formatter.result_file(state_dir)
    @next_step += 1
    state
  end

end

