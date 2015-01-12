# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name        = "net-http-uploadprogress"
  s.version     = NetHttpUploadprogress::VERSION
  s.authors     = ["SKAhack", "Vais Salikhov"]
  s.email       = ["m@skahack.com", "vsalikhov@gmail.com"]
  s.homepage    = "https://github.com/SKAhack/net-http-uploadprogress"
  s.summary     = %q{Get the file uploading progress.}
  s.description = %q{Get the file uploading progress.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '~> 2.0'
  s.add_development_dependency "minitest"
end
