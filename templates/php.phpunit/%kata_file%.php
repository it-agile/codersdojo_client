<?php
// Adapt the code to your code kata %kata_file%.
// Important: Test and production code has to be
//            completely in this file.

require_once 'PHPUnit/Autoload.php';

// Please do not rename the test class. If you change the name, you have to adapt it in run-once.sh.

class %Kata_file%Test extends PHPUnit_Framework_TestCase
{
    public function testFoo() {
        $objectUnderTest = new %Kata_file%();
        $this->assertEquals('foo', $objectUnderTest->foo());
    }
}

class %Kata_file%
{
    public function foo()
    {
        return 'fixme';
    }
}

