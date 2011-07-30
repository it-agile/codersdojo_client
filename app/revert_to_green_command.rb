
class RevertToGreenCommand
	
	def initialize shell, view, meta_config_file, state_reader
		@shell = shell
		@view = view
		@meta_config_file = meta_config_file
		@state_reader = state_reader
	end
	
	def execute_from_shell params
		revert_to_green
	end
	
	def execute
		revert_to_green
	end

	def revert_to_green
		formatter = FilenameFormatter.new
		@state_reader.session_dir = formatter.session_dir @shell.newest_dir_entry(FilenameFormatter.codersdojo_workspace)
		@state_reader.goto_last_state
		state = @state_reader.read_previous_state if @state_reader.state_exist?
		while @state_reader.state_exist? and state.red?
			state = @state_reader.read_previous_state
		end
		if @state_reader.state_exist? and state.green?
			@view.show_revert_to_step @state_reader.next_step+1
			@shell.rm_r @meta_config_file.source_files
			state.files.each do |file|
				dest_file = Filename.new(file).extract_last_path_item.to_s
				@shell.write_file dest_file, @shell.read_file(file)
			end
		else
		  @view.show_no_green_state_to_revert_to
			@state_reader.goto_last_state
		end
	end
	
	def command_key
		'g'
	end
	
	def accepts_shell_command? command
		command == 'revert-to-green'
	end
	
	def continue_test_loop?
		true
	end
	
end
