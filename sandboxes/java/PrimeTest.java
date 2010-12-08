import java.util.*;
import org.junit.*;
import org.junit.Assert.*;
import junit.framework.*;
import junit.textui.TestRunner;

public class PrimeTest extends TestCase {
	
	public static void main(String[] args) {
		TestRunner runner = new TestRunner();
		runner.run(PrimeTest.class);
	}

	public void testPrime2() {
		assertTrue(true);
	}
	
	public void testPrime() {
		List<Integer> expected = new ArrayList<Integer>();
		expected.add(1);
		assertEquals(expected, prime(1));
	}
	
	public List<Integer> prime (int number) {
		List<Integer> result = new ArrayList<Integer>();
		result.add(1);
		return result;
	}
	
}