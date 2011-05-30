// Adapt the code to your code kata primes.

import org.junit.Test
import org.junit.Assert._

class %Kata_file%Test {

  @Test
  def verifyThatFooIsFixed() = {
    val objectUnderTest = new %Kata_file%()
    assertEquals("foo", objectUnderTest.foo())
  }

}

private class %Kata_file% {

  def foo() = {
    "fixme"
  }

}
