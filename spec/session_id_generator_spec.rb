require 'session_id_generator'

describe SessionIdGenerator do
	
	before (:each) do
		@time_mock = mock
		@generator = SessionIdGenerator.new
	end
	
	it "should format id as yyyy-mm-dd_hh-mm-ss" do
		@time_mock.should_receive(:year).and_return 2010
		@time_mock.should_receive(:month).and_return 8
		@time_mock.should_receive(:day).and_return 7
		@time_mock.should_receive(:hour).and_return 6
		@time_mock.should_receive(:min).and_return 5
		@time_mock.should_receive(:sec).and_return 0
		@generator.generate_id(@time_mock).should == "2010-08-07_06-05-00"
	end
	
end

