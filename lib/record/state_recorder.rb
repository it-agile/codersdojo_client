require "meta_config_file"
require "record/text_converter"
require "record/return_code_evaluator"

class StateRecorder
	
	attr_accessor :step, :session_id
	
	def initialize shell, session_id_generator, meta_config_file
		@shell = shell
		@session_id_generator = session_id_generator
		@meta_config_file = meta_config_file
		@filename_formatter = FilenameFormatter.new
	end
	
	def init_session
    @step = 0
    @session_id = @session_id_generator.generate_id
		session_dir = @filename_formatter.session_dir @session_id
    @shell.mkdir_p session_dir
		session_dir
    @shell.cp MetaConfigFile::PROPERTY_FILENAME, session_dir
  end
	
	def record_state files, process
		result = TextConverter.new.remove_escape_sequences process.output
		return_code_evaluator = ReturnCodeEvaluator.new @meta_config_file.success_detection	
    return_code = return_code_evaluator.return_code(process)
    state_dir = @filename_formatter.state_dir @session_id, @step
    now = Time.new
    date = now.strftime "%Y-%m-%d"
    time = now.strftime "%H:%M:%S"
    @shell.mkdir state_dir
    @shell.cp_r files, state_dir
    write_result_file state_dir, result
    write_info_file(state_dir, {:return_code => return_code, :date => "'#{date}'", :time => "'#{time}'", :step => @step})
		@step += 1
	end
	
	def write_result_file state_dir, result
		@shell.write_file @filename_formatter.result_file(state_dir), result
  end
	
	def write_info_file state_dir, properties
		content = properties.collect{|key, value| "#{key}: #{value}"}.join "\n"
    @shell.write_file @filename_formatter.info_file(state_dir), content
	end
	
end

