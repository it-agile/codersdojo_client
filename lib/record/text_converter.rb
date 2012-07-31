class TextConverter

  @@ESCAPE_SEQUENCE_START = 0x1b.chr
  @@ESCAPE_SEQUENCE_END = 0x6d.chr

  def self.ESCAPE_SEQUENCE_START
    @@ESCAPE_SEQUENCE_START
  end

  def self.ESCAPE_SEQUENCE_END
    @@ESCAPE_SEQUENCE_END
  end

  def remove_escape_sequences text
    if text.nil? then return nil end
    text.gsub(/#{@@ESCAPE_SEQUENCE_START}.*?#{@@ESCAPE_SEQUENCE_END}/, '')
  end

end
