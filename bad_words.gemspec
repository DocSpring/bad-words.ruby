# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bad_words/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Fedotov Daniil"]
  gem.email         = ["fedotov.danil@gmail.com"]
  gem.summary   = %q{Swear word detector}
  gem.description       = %q{
    Detects #uck F|_|__C_K and other variations of hidden swear words in text.
    Usage:
        finder = BadWords.new
        finder.find("What the #uck")
        it will return BadWord object
    Transformation rules is defined in form: {"#" => {"symbol"=>"f", "weight" => 2}} (where weight is optional)
    in file conf/rules.yaml 
    List of swear words is located in conf/library.yaml
    Whitelist of english words in conf/whitelist.yaml
    You can also set own rules:
        finder = BadWords.new rules, library, whitelist
  }
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bad_words"
  gem.require_paths = ["lib"]
  gem.version       = BadWords::VERSION
  gem.add_development_dependency('yard')
  gem.add_development_dependency('redcarpet')
end
