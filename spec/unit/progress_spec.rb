require 'progress'

describe Progress do

  it 'should print infos and empty progress in initialization' do
    STDOUT.should_receive(:print).with("2 states to upload")
    STDOUT.should_receive(:print).with("[  ]")
    STDOUT.should_receive(:print).with("\b\b\b")
    Progress.write_empty_progress 2
  end

  it 'should print dots and flush in next' do
    STDOUT.should_receive(:print).with(".")
    STDOUT.should_receive(:flush) 
    Progress.next
  end

  it 'should print empty line in end' do
    STDOUT.should_receive(:puts)
    Progress.end
  end

end
