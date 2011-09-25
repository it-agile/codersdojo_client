require 'filename_formatter'

describe FilenameFormatter do

	before (:each) do
		@formatter = FilenameFormatter.new
  end

	it 'should extract the step number from the state dir name' do
		@formatter.step_number_from_state_dir('state_0').should == 0
		@formatter.step_number_from_state_dir('state_1').should == 1
		@formatter.step_number_from_state_dir('state_01').should == 1
		@formatter.step_number_from_state_dir('state_123').should == 123
	end
	
	it 'should integrate step into the state dir name ' do
		@formatter.state_dir('session_dir', 1).should == "#{FilenameFormatter::WORKSPACE_DIR}/session_dir/state_1"
	end
	
end
