# -*- encoding: utf-8 -*-
lib_dir = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'method_decorators/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Michael Fairley"]
  gem.email         = ["michaelfairley@gmail.com"]
  gem.description   = %q{Python's function decorators for Ruby}
  gem.summary       = %q{Python's function decorators for Ruby}
  gem.homepage      = "http://github.com/michaelfairley/method_decorators"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "method_decorators"
  gem.require_paths = ["lib"]
  gem.version       = MethodDecorators::VERSION

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
end
