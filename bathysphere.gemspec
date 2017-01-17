# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bathysphere/version'

Gem::Specification.new do |spec|
  spec.name          = 'bathysphere'
  spec.version       = Bathysphere::VERSION
  spec.authors       = ['Redbubble', 'Gonzalo Bulnes Guilpain']
  spec.email         = ['developers@redbubble.com', 'gonzalo.bulnes@redbubble.com']

  spec.summary       = %q{Fetch arbitrarily deep properties from YAML files without loosing your breath.}
  spec.description   = %q{Bathysphere takes benefit of a self-describing YAML-based data format to normalize options fetching, so the same option can be stored at different depths in distinct configuration files.}
  spec.homepage      = "https://github.com/redbubble/bathysphere.git"
  spec.license       = "MIT"

  spec.files = Dir["{doc,lib}/**/*", "Gemfile", "LICENSE", "Rakefile", "README.md"]
  spec.test_files = Dir["spec/**/*"]
  spec.require_paths = ['lib']

  spec.add_development_dependency 'aruba', '~> 0.14.0'
  spec.add_development_dependency 'cucumber', '~> 2.0'
  spec.add_development_dependency 'rake', '>= 10.0', '< 12'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

