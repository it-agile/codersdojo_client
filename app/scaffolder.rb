require 'text_template_machine'

class Scaffolder

  ANY_TEMPLATE = "any"

	def initialize shell
		@shell = shell
		@template_machine = create_template_machine
	end

	def create_template_machine
		template_machine = TextTemplateMachine.new @shell
		template_machine.placeholder_values = {
			'sh' => @shell.shell_extension,
			':' => @shell.path_separator,
			'rm' => @shell.remove_command_name
		}
		template_machine
	end

	def list_templates
		templates = @shell.real_dir_entries template_path
		templates.delete ANY_TEMPLATE
		templates.join(', ')
	end

	def scaffold template, kata_file
		@template_machine.placeholder_values['kata_file'] = kata_file
		template = template == '???' ? ANY_TEMPLATE : template
			dir_path = "#{template_path}/#{template}"
			to_copy = @shell.real_dir_entries dir_path
			to_copy.each do |item|
				file_path = "#{dir_path}/#{item}"
				@shell.cp_r file_path, "."
				transform_file_content item
				transform_file_name item
			end
	end
	
	def transform_file_content filename
		if @shell.file?(filename)
			content = @shell.read_file filename
			content = @template_machine.render content
			@shell.write_file filename, content
		end
	end
	
	def transform_file_name filename
		new_filename = @template_machine.render filename
		if new_filename != filename
			@shell.rename filename, new_filename
		end
  end
		
	def template_path
		file_path_elements = @shell.current_file.split '/' 
		file_path_elements[-2..-1] = nil
		(file_path_elements << 'templates').join '/'
	end

end

