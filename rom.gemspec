require File.expand_path("lib/rom/version", __dir__)

Gem::Specification.new do |gem|
  gem.name        = "rom"
  gem.summary     = "Persistence and mapping toolkit for Ruby"
  gem.description = gem.summary
  gem.author      = "Peter Solnica"
  gem.email       = "peter@solnica.online"
  gem.homepage    = "https://rom-rb.org"
  gem.version     = ROM::VERSION.dup
  gem.files       = Dir["CHANGELOG.md", "LICENSE", "README.md", "lib/**/*"]
  gem.license     = "MIT"
  gem.metadata    = {
    "source_code_uri" => "https://github.com/rom-rb/rom",
    "documentation_uri" => "https://api.rom-rb.org/rom/",
    "mailing_list_uri" => "https://discourse.rom-rb.org/",
    "bug_tracker_uri" => "https://github.com/rom-rb/rom/issues"
  }

  gem.required_ruby_version = ">= 2.4.0"

  gem.add_runtime_dependency "concurrent-ruby", "~> 1.1"
  gem.add_runtime_dependency "zeitwerk"
  gem.add_runtime_dependency "dry-core", "~> 0.7", ">= 0.7"
  gem.add_runtime_dependency "dry-inflector", "~> 0.2"
  gem.add_runtime_dependency "dry-container", "~> 0.9"
  gem.add_runtime_dependency "dry-types", "~> 1.5"
  gem.add_runtime_dependency "dry-struct", "~> 1.4"
  gem.add_runtime_dependency "dry-initializer", "~> 3.1"
  gem.add_runtime_dependency "dry-transformer", "~> 0.1"
  gem.add_runtime_dependency "dry-effects", "~> 0.2"
end
