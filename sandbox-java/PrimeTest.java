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
	
	public void testPrime() {
		assertEquals(null, prime(1));
	}
	
	public List<Integer> prime (int number) {
		return null;
	}
	
}