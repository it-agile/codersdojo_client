require 'state_reader'
require 'progress'
require 'filename_formatter'
require 'xml_element_extractor'
require 'rest_client'

class Uploader

  def initialize hostname, framework, session_dir, state_reader = StateReader.new(ShellWrapper.new)
		@hostname = hostname
	  @framework = framework
    @state_reader = state_reader
    @state_reader.session_dir = session_dir
  end

  def upload_kata
    RestClient.post "#{@hostname}#{@@kata_path}", {:framework => @framework}
  end

  def upload_state kata_id
    state = @state_reader.read_next_state
    RestClient.post "#{@hostname}#{@@kata_path}/#{kata_id}#{@@state_path}", {:code => state.code, :result => state.result, :created_at => state.time}
    Progress.next
  end

  def upload_states kata_id
    Progress.write_empty_progress @state_reader.state_count
    while @state_reader.has_next_state
      upload_state kata_id
    end
    Progress.end
  end

  def upload_kata_and_states
    kata = upload_kata
    upload_states(XMLElementExtractor.extract('kata/id', kata))
		finish_url = "#{@hostname}#{@@description_path}/#{XMLElementExtractor.extract('kata/uuid', kata)}"
		summary_url = XMLElementExtractor.extract('kata/short-url', kata)
    "Complete kata information at #{finish_url}"
  end

  def upload
    return upload_kata_and_states if @state_reader.enough_states?
    return "You need at least two states"
  end

  private
  @@kata_path = '/katas'
  @@state_path = '/states'
	@@description_path = '/kata_description'

end

