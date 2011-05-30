# Adapt the code to your code kata %kata_file%.

class %Kata_file%

  def foo
    "fixme"
  end

end

describe %Kata_file%, "" do
	
	before (:each) do
	  @%kata_file% = %Kata_file%.new	
	end
	
		
  it "should return bar" do
		@%kata_file%.foo.should == "bar"
  end

end