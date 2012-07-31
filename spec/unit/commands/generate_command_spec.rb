require 'commands/generate_command'

describe GenerateCommand do

  before (:each) do
    @shell_mock = mock
    @shell_mock.should_receive(:read_file).and_return ""
    @view_mock = mock.as_null_object
    @scaffolder_mock = mock
    @generate_command = GenerateCommand.new @shell_mock, @view_mock, @scaffolder_mock
  end

  it 'should accept filename without extension' do
    @scaffolder_mock.should_receive(:scaffold).with("aFramework", "katafile")
    @generate_command.generate "aFramework", "katafile"
  end

  it 'should accept filename with extension' do
    @scaffolder_mock.should_receive(:scaffold).with("aFramework", "katafile.ext")
    @generate_command.generate "aFramework", "katafile.ext"
  end

end
