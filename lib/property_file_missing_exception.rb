class PropertyFileMissingException < Exception

  attr_accessor :filename

  def initialize filename
    @filename = filename
  end

end
