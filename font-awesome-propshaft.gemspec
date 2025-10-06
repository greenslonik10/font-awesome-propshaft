# -*- encoding: utf-8 -*-
require File.expand_path('../lib/font-awesome-propshaft/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["greenslonik10"]
  gem.email         = ["zazulinnikk@gmail.com"]
  gem.description   = "font-awesome-propshaft provides the Font-Awesome web fonts and stylesheets as a Rails engine for use with the asset pipeline."
  gem.summary       = "an asset gemification of the font-awesome icon font library"
  gem.homepage      = "https://github.com/greenslonik10/font-awesome-propshaft"
  gem.licenses      = ["MIT", "SIL Open Font License"]

  gem.files         = `git ls-files -- {app,bin,lib,test,spec}/* {LICENSE*,Rakefile,README*}`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.name          = "font-awesome-propshaft"
  gem.require_paths = ["lib"]
  gem.version       = FontAwesomePropshaft::Rails::VERSION

  gem.add_dependency "railties", ">= 3.2", "< 8.0"
  gem.add_dependency "propshaft"
  gem.add_dependency "sassc"

  gem.add_development_dependency "activesupport"

  gem.required_ruby_version = '>= 1.9.3'
end
