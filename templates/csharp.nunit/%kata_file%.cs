using System;
using NUnit.Framework;

[TestFixture]
public class %Kata_file%Test
{
    [Test]
    public void testFoo()
    {
        Test object_under_test = new Test();
        Assert.AreEqual("foo", object_under_test.foo());
    }
}

public class %Kata_file%
{
    public String foo(){
        return "fixme";
    }
}