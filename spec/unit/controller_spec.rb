require 'controller'

describe Controller, "executing command setup" do

	before (:each) do
		@shell_mock = mock
		@shell_mock.should_receive(:read_file).and_return ""
		@view_mock = mock.as_null_object
		@scaffolder_mock = mock
		@controller = Controller.new @shell_mock, @view_mock, @scaffolder_mock, "my_host"
  end

  it 'should accept filename without extension' do
		@scaffolder_mock.should_receive(:scaffold).with("aFramework", "katafile")
		@controller.generate "aFramework", "katafile"
  end

  it 'should accept filename with extension' do
		@scaffolder_mock.should_receive(:scaffold).with("aFramework", "katafile.ext")
		@controller.generate "aFramework", "katafile.ext"
  end

end
