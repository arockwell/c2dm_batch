# -*- encoding: utf-8 -*-
root = File.expand_path('../', __FILE__)
lib = "#{root}/lib"

$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "c2dm_batch"
  s.version     = '0.2.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Rockwell"]
  s.email       = ["arockwell@gmail.com"]
  s.homepage    = "http://alexrockwell.org"
  s.summary     = %q{Gem to send android c2dm notifications in batch}
  s.description = %q{Gem to send android c2dm notifications in batch}

  s.executables = `cd #{root} && git ls-files bin/*`.split("\n").collect { |f| File.basename(f) }
  s.files = `cd #{root} && git ls-files`.split("\n")
  s.require_paths = %w(lib)
  s.test_files = `cd #{root} && git ls-files -- {features,test,spec}/*`.split("\n")

  s.add_development_dependency "rspec", "~> 1.0"
  s.add_dependency "typhoeus", "= 0.2.4"
  s.add_dependency "json", "= 1.6.1"
end
