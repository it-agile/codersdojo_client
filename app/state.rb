class State

  attr_accessor :time, :files, :result, :return_code

  def initialize time=nil, files=nil, result=nil, return_code=nil
    @time = time
    @files = files
    @result = result
    @return_code = return_code
  end

end
