-- Adapt the code to your code kata %kata_file%.

import Test.HUnit

foo :: String
foo = "fixme"


test1 = TestCase (do assertEqual "" "foo" (foo))

tests :: Test
tests = TestList [TestLabel "test1" test1]

main :: IO Counts
main = do runTestTT tests

