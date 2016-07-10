# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gpsd_client/version'

Gem::Specification.new do |spec|
  spec.name          = "gpsd_client"
  spec.version       = GpsdClient::VERSION
  spec.authors       = ["rccursach"]
  spec.email         = ["rccursach@gmail.com"]

#  if spec.respond_to?(:metadata)
#    spec.metadata['allowed_push_host'] = "Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
#  end

  spec.summary       = %q{Ruby gem for GPSD.}
  spec.description   = %q{A simple GPSd client intended for use on the Raspberry Pi.}
  spec.homepage      = "https://github.com/rccursach/gpsd_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  #spec.files         = `git ls-files`.split("\n").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-core", "~> 3.2.1"
  spec.add_development_dependency "rspec-expectations", "~> 3.2.1"
end
