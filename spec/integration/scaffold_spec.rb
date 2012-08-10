require "scaffold/scaffolder"

describe Scaffolder do

  let(:shell) { ShellWrapper.new }
  let(:working_dir) { File.expand_path("spec/fixtures/working") }

  subject { Scaffolder.new(shell) }

  before(:each) do
    shell.stub(:shell_extension => 'exo', :remove_command_name => 'nix', :path_separator => ";", :dir_separator => "/")
    subject.stub(:template_path => File.expand_path('spec/fixtures'), :working_directory => working_dir)
  end

  after(:each) do
    ['.meta', 'README', 'foobar.ro', 'run-once.exo', 'run-endless.exo'].each do |file|
      begin
        FileUtils.rm("#{working_dir}/#{file}")
      rescue
        # we don't care
      end
    end
  end

  it "totally works" do
    subject.scaffold 'roobi.xunit', 'foobar'

    File.read("#{working_dir}/.meta").should eq(<<-TXT)
framework: roobi.xunit
source_files: .*\\.ro

TXT

    File.read("#{working_dir}/README").should eq(<<-TXT)
Do it with run-once.exo or run-endless.exo.
If you get frustrated, just `nix` everything.
TXT

    File.read("#{working_dir}/foobar.ro").should eq(<<-TXT)
class Foobar
end
TXT

    File.read("#{working_dir}/run-once.exo").should eq(<<-TXT)
rspec foobar.rb
TXT

    File.read("#{working_dir}/run-endless.exo").should eq(<<-TXT)
codersdojo start run-once.exo
TXT
  end

  it "also does 'any' template" do
    subject.scaffold '???', 'foobar'

    File.read("#{working_dir}/.meta").should eq(<<-TXT)
framework: any
    TXT
  end
end
