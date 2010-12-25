require "scaffolder"

describe Scaffolder do

	before (:each) do
		@shell_mock = mock
		@shell_mock.should_receive(:shell_extension).any_number_of_times.and_return "cmd"
		@shell_mock.should_receive(:remove_command_name).any_number_of_times.and_return "del"
		@shell_mock.should_receive(:path_separator).any_number_of_times.and_return ";"
		@shell_mock.should_receive(:current_file).any_number_of_times.and_return("aDir/app/aFile.rb")
		@scaffolder = Scaffolder.new @shell_mock
	end
	
  it "should compute template path from location of ruby source file" do
		@scaffolder.template_path.should == "aDir/templates"
  end

	it "should retrieve templates from directories within the template directory" do
		@shell_mock.should_receive(:real_dir_entries).with("aDir/templates").and_return ['any', 't1', 't2', 't3']
		@scaffolder.list_templates.should == 't1, t2, t3'
	end
	
	it "should scaffold the files and directories for a given template" do
		@shell_mock.should_receive(:real_dir_entries).with("aDir/templates/a.template").and_return ["a", "b"]
		@shell_mock.should_receive(:cp_r).with "aDir/templates/a.template/a", "."
		@shell_mock.should_receive(:cp_r).with "aDir/templates/a.template/b", "."
		@scaffolder.scaffold "a.template", 'myKata'
	end
	
	it "should use 'any' when the given template doesn't exist" do
		@shell_mock.should_receive(:real_dir_entries).with("aDir/templates/unknown.template").and_throw Exception
		@shell_mock.should_receive(:real_dir_entries).with("aDir/templates/any").and_return ["a"]
		@shell_mock.should_receive(:cp_r).with "aDir/templates/any/a", "."
		@scaffolder.scaffold "unknown.template", 'myKata'
	end
	
	it "should replace placeholder in template file README and shell scripts" do
		@shell_mock.should_receive(:real_dir_entries).with("aDir/templates/a.template").
			and_return ["a", "README", "run-once.sh", "run-endless.sh"]
		@shell_mock.should_receive(:cp_r).with "aDir/templates/a.template/a", "."
		@shell_mock.should_receive(:cp_r).with "aDir/templates/a.template/README", "."
		@shell_mock.should_receive(:cp_r).with "aDir/templates/a.template/run-once.sh", "."
		@shell_mock.should_receive(:cp_r).with "aDir/templates/a.template/run-endless.sh", "."
		@shell_mock.should_receive(:read_file).with("README").and_return '%rm% %kata_file%\nb.%sh%\nc%:%d'
		@shell_mock.should_receive(:write_file).with "README", 'del myKata\nb.cmd\nc;d'
		@shell_mock.should_receive(:read_file).with("run-once.sh").and_return "%rm% a\nb.%sh%\nc%:%d"
		@shell_mock.should_receive(:write_file).with "run-once.sh", "del a\nb.cmd\nc;d"
		@shell_mock.should_receive(:read_file).with("run-endless.sh").and_return "%rm% a\nb.%sh%\nc%:%d"
		@shell_mock.should_receive(:write_file).with "run-endless.sh", "del a\nb.cmd\nc;d"
		@scaffolder.scaffold "a.template", 'myKata'
	end

end

