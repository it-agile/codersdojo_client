// Adapt the code to your code kata %kata_file%.

import org.junit.*;
import static org.junit.Assert.*;

public class %Kata_file%Test {
	
	@Test
	public void testFoo() {
		%Kata_file% object_under_test = new %Kata_file%();
		assertEquals("foo", object_under_test.foo());
	}
	
}

class %Kata_file% {

	public String foo() {
		return "fixme";
	}
	
	
}