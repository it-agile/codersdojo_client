require 'tempfile'

codersdojo_dir = File.expand_path(File.join(File.dirname(__FILE__), '../..', 'app'))
$LOAD_PATH.unshift(codersdojo_dir) unless $LOAD_PATH.include?(codersdojo_dir)
require 'codersdojo'

describe CodersDojo, "with params 'setup ruby.test-unit mykata'" do
	
	before (:all) do
      @current_dir = Dir.pwd
		Dir.chdir Dir.tmpdir
		dirname = 'codersojo-' + Time.now.to_s.gsub(/ /,'_')
		FileUtils.mkdir dirname
		Dir.chdir dirname
		@workdir = Dir.pwd
		puts "Generating to workdir #{@workdir}"
		params = ['setup', 'ruby.test-unit', 'mykata']
		@codersdojo = CodersDojo.new params
		@codersdojo.run
	end

    after(:all) do
      Dir.chdir @current_dir
    end

	it "should generate dir structure to workdir" do
		Dir.entries(@workdir).size.should > 0
	end
	
	it "should resolve all placeholders in filenames" do
		Dir.glob(@workdir + '/*%*%*').size.should == 0
	end
	
end

