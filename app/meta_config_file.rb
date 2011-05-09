class MetaConfigFile

	PROPERTY_FILENAME = '.meta'	
	
	def initialize shell
		@shell = shell
	end
	
	def framework_property
		properties['framework']
	end

	def properties
	  @shell.read_properties PROPERTY_FILENAME
	end
	
end
