require "record/return_code_evaluator"

describe ReturnCodeEvaluator do

  it "should use the return code per default" do
    evaluator = ReturnCodeEvaluator.new nil
    process_mock = mock
    process_mock.should_receive(:return_code).and_return 0
    evaluator.return_code(process_mock).should == 0
    process_mock.should_receive(:return_code).and_return 1
    evaluator.return_code(process_mock).should == 1		
  end

  it "should evaluate output when success detection regex is specifed" do
    evaluator = ReturnCodeEvaluator.new "0 failures, 0 errors"
    process_mock = mock
    process_mock.should_receive(:output).and_return "Fail"
    evaluator.return_code(process_mock).should_not == 0
    process_mock.should_receive(:output).and_return "10 failures, 0 errors"
    evaluator.return_code(process_mock).should_not == 0
    process_mock.should_receive(:output).and_return " 0 failures, 0 errors"
    evaluator.return_code(process_mock).should == 0
  end

end
