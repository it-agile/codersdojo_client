class FileTransformer
	
	def initialize shell
		@shell =  shell
	end
	
	def transform text, kata_file
		make_os_specific(replace_placeholder text, kata_file)
	end
	
	def replace_placeholder text, kata_file
		text.gsub '#{kata_file}', kata_file
	end
	
	def make_os_specific text
		text.gsub('%sh%', @shell.shell_extension).gsub('%:%', @shell.path_separator).gsub('%rm%', @shell.remove_command_name)
	end
	
end
