require 'text_template_machine'

describe TextTemplateMachine do
	
	before (:each) do
		shell_mock = mock
		@machine = TextTemplateMachine.new shell_mock
		@placeholder_values = {'a' => 'A', 'wo' => 'world', 'm' => 'my'}
		@machine.placeholder_values = @placeholder_values
	end
	
	it "should not modifiy text without placeholders" do
		@machine.render('Some text without placeholders.').should == 'Some text without placeholders.'
	end
	
	it "should not modifiy unknown placeholders" do
		@machine.render('Hello %unknown%').should == 'Hello %unknown%'
	end

	it "should resolve placeholders" do
		@machine.render('Hello %wo%, %m% %wo%').should == 'Hello world, my world'
	end

	it "should not modify case of first letter" do
		@machine.render('Hello %wo%').should == 'Hello world'
		@machine.render('Hello %Wo%').should == 'Hello World'
	end
	
	it "should use added placeholder" do
		@machine.placeholder_values['xxx'] = 'xxx-value'
		@machine.render('%xxx%').should == 'xxx-value'
	end
	
	it "should use newest placeholder value" do
		@machine.placeholder_values['a'] = 'b'
		@machine.render('%a%').should == 'b'
	end
	
end

