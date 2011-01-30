class State

  attr_accessor :time, :code, :result

  def initialize time=nil, code=nil, result=nil
    @time = time
    @code = code
    @result = result
  end

end
