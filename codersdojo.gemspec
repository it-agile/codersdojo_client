Gem::Specification.new do |s|
   s.version = "1.1.00"
   s.name = %q{codersdojo}
   s.date = %q{2011-01-18}
   s.authors = ["CodersDojo-Team"]
   s.email = %q{codersdojo@it-agile.de}
   s.summary = %q{Client for CodersDojo.org}
   s.homepage = %q{http://www.codersdojo.org/}
   s.description = %q{Client executes tests in an endless loop and logs source code and test result.}
   s.files = Dir["app/*.rb"] + Dir["templates/**/*"] + Dir["lib/*"]
   s.rubyforge_project = 'codersdojo'
   s.has_rdoc = true
   s.test_files = Dir['spec/*']
   s.executables = ['codersdojo']
   s.add_dependency('rest-client')
end
