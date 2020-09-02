require_relative 'lib/get/version'

Gem::Specification.new do |spec|
  spec.name          = "get"
  spec.version       = Get::VERSION
  spec.authors       = ["Ben Ubois"]
  spec.email         = ["ben@benubois.com"]

  spec.summary       = %q{HTTP GET}
  spec.description   = %q{Does a bare-bones HTTP GET request.}
  spec.homepage      = "https://github.com/feedbin/get"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "socketry"
  spec.add_runtime_dependency "addressable"
  spec.add_runtime_dependency "http-parser"
end
