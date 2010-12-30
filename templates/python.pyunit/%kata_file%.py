# Adapt the code to your code kata %kata_file%.
# Important: Test and production code has to be
#            completely in this file.

import unittest

class %Kata_file%:

    def foo(self):
	    return "fixme"


class Test%Kata_file%(unittest.TestCase):

    def test_foo(self):
        object_under_test = %Kata_file%()
        self.assertEqual("foo", object_under_test.foo())

if __name__ == '__main__':
    unittest.main()
