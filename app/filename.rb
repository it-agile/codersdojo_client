class Filename
	
	DIR_SEPARATOR = '/'
	WINDOWS_DIR_SEPARATOR = '\\'
	
	attr_accessor :path_items
	
	def initialize filename
		filename = filename.gsub(WINDOWS_DIR_SEPARATOR, DIR_SEPARATOR)
		@path_items = filename.split(DIR_SEPARATOR).delete_if{|item| item.empty?}
		@absolute_path = filename.start_with? DIR_SEPARATOR
	end
	
	def absolute_path?
		@absolute_path
	end
	
	def relative_path?
		not absolute_path?
	end
	
	def without_extension 
		if @path_items.size > 0 and @path_items.last.include? '.' then
			Filename.new(to_s.split('.')[0..-2].join('.'))
		else
			clone
		end
	end
	
	def extract_last_path_item
		Filename.new(nil_to_empty_string @path_items.last)
	end
	
	def remove_last_path_item
		Filename.new(make_string(@path_items[0..-2]))
	end
	
	def to_unix_s
		make_string @path_items
	end
	
	def to_windows_s
		make_string @path_items, WINDOWS_DIR_SEPARATOR
	end
	
	def to_s
		to_unix_s
	end
	
private
	
	def make_string the_path_items, seperator=DIR_SEPARATOR
		prefix = absolute_path? ? seperator : ''
		prefix + the_path_items.join(seperator)
	end

	def nil_to_empty_string object
		object.nil? ? "" : object
	end
	
end
