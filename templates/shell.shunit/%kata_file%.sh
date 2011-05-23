function %kata_file%()
{
	result="fixme"
}

function test%Kata_file%()
{
	%kata_file%
	assertEquals "foo" ${result}
}

