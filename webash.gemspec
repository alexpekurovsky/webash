Gem::Specification.new do |s|
  s.name        = 'webash'
  s.version     = '0.1.0'
  s.date        = '2017-06-28'
  s.summary     = "Webash"
  s.description = "Expose your bash scripts to browser"
  s.authors     = ["Alex Pekurovsky"]
  s.email       = 'alex.pekurovskiy@gmail.com'
  s.add_runtime_dependency 'deep_merge', '~> 1'
  s.files       = ["lib/webash.rb", "examples/config.yaml.sample"]
  s.executables << 'webash'
  s.homepage    = 'http://rubygems.org/gems/webash'
  s.license     = 'MIT'
end
