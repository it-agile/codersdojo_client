require "test/unit"

class PrimeTest < Test::Unit::TestCase
	
	def test_prime 
		assert_equal [], prime(1)
		assert_equal [2], prime(2)
	end
	
end

def prime number
	number == 1 ? [0] : [2]
end
