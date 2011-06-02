Gem::Specification.new do |s|
  s.name = "parslet-css"
  s.version = "0.0.1"
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.homepage = "http://github.com/spk/parslet-css"
  s.authors = "Laurent Arnoud"
  s.email = "laurent.arnoud@spkdev.net"
  s.description = "CSS parser with Parslet"
  s.summary = "CSS parser with Parslet grammar tool"
  s.extra_rdoc_files = %w(README.markdown)
  s.files = Dir["LICENSE", "README.markdown", "Gemfile", "lib/**/*.rb"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.add_dependency "parslet", "~>1.2"
  s.add_development_dependency "minitest", "~>2.0"
end
