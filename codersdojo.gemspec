Gem::Specification.new do |s|
   s.version = "1.5.15"
   s.date = %q{2012-01-28}
   s.name = %q{codersdojo}
   s.authors = ["CodersDojo-Team"]
   s.email = %q{codersdojo@it-agile.de}
   s.summary = %q{Client for CodersDojo.org}
   s.homepage = %q{http://www.codersdojo.org/}
   s.description = %q{Client executes tests in an endless loop and logs source code and test result for later uplaod.}
   s.files = Dir["lib/**/*"] + Dir["templates/**/*"] + Dir["templates/**/.*"]
   s.rubyforge_project = 'codersdojo'
   s.has_rdoc = true
   s.test_files = Dir['spec/*']
   s.executables = ['codersdojo']
   s.required_ruby_version = '>= 1.8.6'

   s.add_dependency('json', '>= 1.4.6')
   s.add_dependency('rest-client', '>= 1.6.1')
   s.add_dependency('term-ansicolor', '>= 1.0.5')
   s.add_dependency('shell-utils', '= 0.1.1')
   s.add_dependency('flote', '= 0.0.2')

   s.add_development_dependency('rake', '~> 10.0.0')
end
