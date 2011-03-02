class State

  attr_accessor :time, :code, :result, :return_code

  def initialize time=nil, code=nil, result=nil, return_code=nil
    @time = time
    @code = code
    @result = result
    @return_code = return_code
  end

end
