%kata_file% = require './%kata_file%'

describe 'The %Kata_file%', ->
	it 'should return foo', ->
		expect(%kata_file%.foo()).toBe 'foo'

