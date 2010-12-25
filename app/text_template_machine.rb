class TextTemplateMachine
	
	attr_accessor :placeholder_values
	
	def initialize shell
		@shell =  shell
		@placeholder_values = []
	end
	
	def render text
		@placeholder_values.each do |placeholder_value|
			placeholder = placeholder_value.first
			value = placeholder_value.last
			text = replace_placeholder text, placeholder, value
		end
		text
	end
	
	def replace_placeholder text, placeholder, value
		text = text.gsub "%#{placeholder}%", value
		placeholder_cap = placeholder.capitalize
		value_cap = value.capitalize
		text.gsub "%#{placeholder_cap}%", value_cap
	end
	
end
