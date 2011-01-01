class TextConverter
	
	ESCAPE_SEQUENCE_START = 0x1b.chr
	ESCAPE_SEQUENCE_END = 0x6b.chr
	
	def remove_escape_sequences text
		text.gsub(/#{ESCAPE_SEQUENCE_START}.*?#{ESCAPE_SEQUENCE_END}/, '')
	end
	
end
