require 'file_transformer'

class Scaffolder

  ANY_TEMPLATE = "any"

	def initialize shell
		@shell = shell
		@file_transformer = FileTransformer.new shell
	end

	def list_templates
		templates = @shell.real_dir_entries template_path
		templates.delete ANY_TEMPLATE
		templates.join(', ')
	end

	def scaffold template, kata_file
		begin
			dir_path = "#{template_path}/#{template}"
			to_copy = @shell.real_dir_entries dir_path
		rescue
			dir_path = "#{template_path}/#{ANY_TEMPLATE}"
			to_copy = @shell.real_dir_entries dir_path
		end
		to_copy.each do |item|
			file_path = "#{dir_path}/#{item}"
			@shell.cp_r file_path, "."
			transform_file item, kata_file
		end
	end
	
	def transform_file file, kata_file
		if file == "README" or file.end_with?(".sh")
			content = @shell.read_file file
			content = @file_transformer.transform content, kata_file
			@shell.write_file file, content
		end
	end
		
	def template_path
		file_path_elements = @shell.current_file.split '/' 
		file_path_elements[-2..-1] = nil
		(file_path_elements << 'templates').join '/'
	end

end

