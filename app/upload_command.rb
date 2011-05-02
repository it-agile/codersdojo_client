require 'uploader'

class UploadCommand

	PROPERTY_FILENAME = '.meta'

	attr_accessor :uploader

	def initialize shell, view, hostname
		@shell = shell
		@view = view
		@hostname = hostname
		@uploader = Uploader.new(hostname, '', '')
	end

	def execute
		upload nil, nil
	end

	def upload framework, session_directory, open_browser=true
		formatter = FilenameFormatter.new
		framework = framework_property unless framework
		if not session_directory then
			session_directory = formatter.session_dir @shell.newest_dir_entry(FilenameFormatter.codersdojo_workspace) 
		end
		@view.show_upload_start session_directory, @hostname, framework
		@uploader.framework = framework
		@uploader.session_dir = session_directory
		upload_result = @uploader.upload
		 @view.show_upload_result upload_result
		url = upload_result.split.last
		if open_browser then 
			@shell.open_with_default_app url
		end
	end
	
	def command_key
		'u'
	end
	
	def framework_property
		properties['framework']
	end

	def properties
	  @shell.read_properties PROPERTY_FILENAME
	end
	
end
