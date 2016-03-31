require File.expand_path("../lib/rspec/by/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = 'rspec-by'
  s.version       = RSpec::By::VERSION
  s.date          = '2016-03-30'
  s.summary       = "RSpec formatter"
  s.description   = "An RSpec formatter that provides step-like message output"
  s.authors       = ["Masaki Matsuo"]
  s.email         = 'masaki.matsuo@pnmac.com'
  s.files         = `git ls-files`.split($\)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.homepage      = 'https://github.com/sleepn247/rspec-by'
  s.license       = 'MIT'

  s.add_runtime_dependency("rspec-core", ">= 3")
end
