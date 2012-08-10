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
		grouped_items = items.group_by{|item| item.split(working_directory).first}
		group_strings = grouped_items.collect{|group| group.last.join ', '}
		"#{indent_string}* " + group_strings.join("\n#{indent_string}* ")
	end

  def scaffold template, kata
    kata = Filename.new(kata).without_extension.to_s
    template = template == '???' ? ANY_TEMPLATE : template
    source_path = "#{template_path}/#{template}"
    @shell.real_dir_entries(source_path).each do |item|
      source = "#{source_path}/#{item}"
      destination = convert "#{working_directory}/#{item}", kata
      @shell.cp_r source, destination
      if @shell.file? destination
        content = convert @shell.read_file(destination), kata
        @shell.write_file destination, content
      end
    end
  end

  def convert text, kata
    @template_machine.render text, 'kata_file' => kata
  end

	def template_path
		file_path_elements = Scaffolder::current_file.split '/'
    while file_path_elements.last != 'lib' do
	    file_path_elements.pop
    end
    file_path_elements.pop
		(file_path_elements << 'templates').join '/'
	end

  def self.current_file
	  __FILE__
  end

  def working_directory
    '.'
  end

end

