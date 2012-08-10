require "scaffold/scaffolder"

describe Scaffolder do

	before (:each) do
		@shell_mock = mock
		@shell_mock.should_receive(:shell_extension).any_number_of_times.and_return "cmd"
		@shell_mock.should_receive(:remove_command_name).any_number_of_times.and_return "del"
		@shell_mock.should_receive(:path_separator).any_number_of_times.and_return ";"
		@shell_mock.should_receive(:dir_separator).any_number_of_times.and_return "/"
		Scaffolder.should_receive(:current_file).any_number_of_times.and_return("aDir/lib/aFile.rb")
		@scaffolder = Scaffolder.new @shell_mock
	end
	
  it "should compute template path from location of ruby source file" do
		@scaffolder.template_path.should == "aDir/templates"
  end

	it "should retrieve templates from directories within the template directory" do
		@shell_mock.should_receive(:real_dir_entries).with("aDir/templates").and_return ['any', 't1', 't2', 't3']
		@scaffolder.list_templates.should == 't1, t2, t3'
	end
	
	it "should format dotted list with indentation" do
		@scaffolder.as_dotted_list(2, ["a.b", "a.c", "b.d", "e"]).should == "  * a.b, a.c\n  * b.d\n  * e"
	end

end

