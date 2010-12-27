# Adapt the code to your code kata %kata_file%.

require 'test/unit'

class %Kata_file%Test < Test::Unit::TestCase

  def test_broken
    foo = %Kata_file%.new
    assert_equal("Foo.bar", foo.bar)
  end

end

class %Kata_file%

  def bar
    "fixme"
  end

end