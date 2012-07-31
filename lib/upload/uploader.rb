require 'json'
require 'state'
require 'state_reader'
require 'upload/xml_element_extractor'
require 'upload/encoding_adjuster'
require 'shellutils/progress'
require 'filename_formatter'
require 'rest_client'
require 'shellutils/shell_wrapper'
require 'shellutils/session_zipper'

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
    @session_dir = dir
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
    adjuster = EncodingAdjuster.new
    kata_data = {:framework => @framework}
    states_data = states.each_with_index do |state,index|
      kata_data["states[#{index}]"] = {:code => state.file_contents.collect{|content| adjuster.adjust(content)},
        :result => adjuster.adjust(state.result), :green => state.green?,
        :created_at => state.time}
    end
    RestClient.post "#{@hostname}#{@@kata_path}", kata_data
  end

  def upload_zipped_session
    private_url = upload_zipped_kata zip_kata
    "Complete kata information at #{private_url}"
  end

  def zip_kata
    SessionZipper.new.compress @session_dir
  end

  def upload_zipped_kata zip_file_name
    RestClient::Resource.new("#{@hostname}#{@@zipped_kata_path}").post(:transfer => { :path => "kata.zip" }, :upload => File.new(zip_file_name, 'rb'))
  end

  private
  @@kata_path = '/katas'
  @@state_path = '/states'
  @@description_path = '/kata_description'
  @@zipped_kata_path = '/zipped_katas'

end

