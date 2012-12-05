# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bad_words/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Fedotov Daniil"]
  gem.email         = ["fedotov.danil@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bad_words"
  gem.require_paths = ["lib"]
  gem.version       = BadWords::VERSION
  gem.add_development_dependency('rspec')
end
