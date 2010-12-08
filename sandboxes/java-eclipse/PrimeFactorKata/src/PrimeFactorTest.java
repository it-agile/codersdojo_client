import junit.framework.TestCase;
import junit.textui.TestRunner;

import org.junit.Test;



public class PrimeFactorTest extends TestCase {

	public static void main(String[] args) {
        TestRunner.run(PrimeFactorTest.class);
	}

	
	public void testPrimes() {
		assertEquals(1, primeFactors(1));
	}
	
	public int primeFactors(int number) {
		return 2;
	}
	
}
