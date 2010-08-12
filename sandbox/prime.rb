require "test/unit"

class RomTest < Test::Unit::TestCase
	
	def test_prime 
		assert_equal [], prime(1)
		assert_equal [2], prime(2)
	end
	
end

def prime number
	number == 1 ? [1] : [2]
end
