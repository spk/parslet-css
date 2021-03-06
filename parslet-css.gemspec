require File.join(File.dirname(__FILE__), 'lib', 'parslet-css', 'version')

Gem::Specification.new do |s|
  s.name = "parslet-css"
  s.version = ParsletCSS::VERSION
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.homepage = "http://github.com/spk/parslet-css"
  s.authors = "Laurent Arnoud"
  s.email = "laurent@spkdev.net"
  s.description = "CSS parser with Parslet"
  s.summary = "CSS parser with Parslet grammar tool"
  s.extra_rdoc_files = %w(README.markdown)
  s.files = Dir["LICENSE", "README.markdown", "Gemfile", "data/*", "lib/**/*.rb"]
  s.test_files = Dir.glob("test/*_test.rb")
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.add_dependency "parslet", "~>1.2"
  s.add_development_dependency "minitest", "~>2.0"
end
