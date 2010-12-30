# Adapt the code to your code kata %kata_file%.
# Important: Test and production code has to be
#            completely in this file.

require 'test/unit'

class %Kata_file%Test < Test::Unit::TestCase

  def test_foo
    object_under_test = %Kata_file%.new
    assert_equal("foo", object_under_test.foo)
  end

end

class %Kata_file%

  def foo
    "fixme"
  end

end