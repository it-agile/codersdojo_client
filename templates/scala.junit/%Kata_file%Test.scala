// Adapt the code to your code kata primes.
// Important: Test and production code has to be
//            completely in this file.

import org.scalatest.junit.JUnitSuite
import org.scalatest.junit.ShouldMatchersForJUnit
import org.junit.Test
import Primes._

class PrimesTest extends JUnitSuite with ShouldMatchersForJUnit {

  @Test
  def verifyThatOneIsPrime() = {
    foo() should be("fixed")
  }

}

object Primes {

  def foo() = {
    "fixme"
  }

}
