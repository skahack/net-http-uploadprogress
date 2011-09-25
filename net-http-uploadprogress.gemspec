# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name        = "net-http-uploadprogress"
  s.version     = NetHttpUploadprogress::VERSION
  s.authors     = ["SKAhack"]
  s.email       = ["m@skahack.com"]
  s.homepage    = "https://github.com/SKAhack/net-http-uploadprogress"
  s.summary     = %q{Get the file uploading progress.}
  s.description = %q{Get the file uploading progress.}

  s.rubyforge_project = "net-http-uploadprogress"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
