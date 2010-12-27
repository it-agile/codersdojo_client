# create gem: build_gem.sh
# push gem: gem push deploy/codersdojo-0.9.11.gem
# install gem: sudo gem install codersdojo --no-ri --no-rdoc 

Gem::Specification.new do |s|
   s.version = "0.9.11"
   s.name = %q{codersdojo}
   s.date = %q{2010-12-10}
   s.authors = ["CodersDojo-Team"]
   s.email = %q{codersdojo@it-agile.de}
   s.summary = %q{Client for CodersDojo.org}
   s.homepage = %q{http://www.codersdojo.org/}
   s.description = %q{Client executes tests in an endless loop and logs source code and test result.}
   s.files = Dir["app/*.rb"] + Dir["templates/**/*"]
   s.rubyforge_project = 'codersdojo'
   s.has_rdoc = false
   s.test_files = Dir['spec/*']
   s.executables = ['codersdojo']
   s.add_dependency('rest-client')
end
