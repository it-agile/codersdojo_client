require 'scaffold/text_template_machine'
require 'filename_formatter'

class Scaffolder

  ANY_TEMPLATE = "any"

	def initialize shell
		@shell = shell
		@template_machine = TextTemplateMachineFactory.create @shell
		@filename_formatter = FilenameFormatter.new
	end

	def list_templates
		templates = @shell.real_dir_entries template_path
		templates.delete ANY_TEMPLATE
		templates.join(', ')
	end

	def list_templates_as_dotted_list indentation
		templates = @shell.real_dir_entries template_path
		templates.delete ANY_TEMPLATE
		as_dotted_list indentation, templates
	end
	
	def as_dotted_list indentation, items
		indent_string = ' '*indentation
		grouped_items = items.group_by{|item| item.split('.').first}
		group_strings = grouped_items.collect{|group| group.last.join ', '}
		"#{indent_string}* " + group_strings.join("\n#{indent_string}* ")
	end

	def scaffold template, kata_file
		@template_machine.placeholder_values['kata_file.ext'] = kata_file
		@template_machine.placeholder_values['kata_file'] = Filename.new(kata_file).without_extension.to_s
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
		file_path_elements = Scaffolder::current_file.split '/' 
		file_path_elements[-2..-1] = nil
		(file_path_elements << 'templates').join '/'
	end

  def self.current_file
	  __FILE__
  end

end

