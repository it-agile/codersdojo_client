class UploadCommand

	attr_accessor :uploader

	def initialize shell, view, hostname
		@shell = shell
		@view = view
		@hostname = hostname
		@uploader = Uploader.new(hostname, '', '')
	end

	def upload framework, session_directory, open_browser=true
		formatter = FilenameFormatter.new
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
	
end
