require 'json'
require 'state'
require 'state_reader'
require 'progress'
require 'filename_formatter'
require 'xml_element_extractor'
require 'rest_client'
require 'shell_wrapper'

class Uploader

	attr_reader :states
	attr_accessor :framework
	
  def initialize hostname, framework, session_dir, state_reader = StateReader.new(ShellWrapper.new)
	  @states = []
		@hostname = hostname
	  @framework = framework
    @state_reader = state_reader
    @state_reader.session_dir = session_dir
  end

	def session_dir= dir
		@state_reader.session_dir = dir
	end

  def upload
    return upload_kata_and_states if @state_reader.enough_states?
    return "You need at least two states"
  end

  def upload_kata_and_states
		read_states
    kata = upload_kata
		finish_url = "#{@hostname}#{@@description_path}/#{XMLElementExtractor.extract('kata/private-uuid', kata)}"
    "Complete kata information at #{finish_url}"
  end

	def read_states
		@state_reader.reset
		while @state_reader.has_next_state
			@states << @state_reader.read_next_state
		end
	end

  def upload_kata
		kata_data = {:framework => @framework}
		states_data = states.each_with_index do |state,index|
			green = state.return_code == 0
			kata_data["states[#{index}]"] = {:code => state.files, :result => state.result, :green => green, 
				:created_at => state.time}
		end
    RestClient.post "#{@hostname}#{@@kata_path}", kata_data
  end

  private
  @@kata_path = '/katas'
  @@state_path = '/states'
	@@description_path = '/kata_description'

end

