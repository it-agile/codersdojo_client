class MetaConfigFile

  PROPERTY_FILENAME = '.meta'

  def initialize shell
    @shell = shell
  end

  def framework_property
    properties['framework']
  end

  def source_files
    end_of_string = '\Z'
    properties['source_files'] + end_of_string
  end

  def success_detection
    properties['success_detection']
  end

  def properties
    @properties = @shell.read_properties PROPERTY_FILENAME unless @properties
    @properties
  end

end
