require_relative 'lib/scraper_rb/version'

Gem::Specification.new do |spec|
  spec.name          = "scraper_rb"
  spec.version       = ScraperRb::VERSION
  spec.authors       = ["Prompt API"]
  spec.email         = ["Prompt API"]

  spec.summary       = %q{Ruby wrapper for Prompt API's Scraper Checker API}
  spec.homepage      = "https://github.com/promptapi/scraper_rb"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/promptapi/scraper_rb"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]
  spec.add_development_dependency 'wirble', '~> 0.1.3'
  spec.add_development_dependency 'awesome_print', '~> 1.8'
  spec.add_development_dependency 'bond', '~> 0.5.1'
  spec.add_development_dependency 'colorize', '~> 0.8.1'

  spec.add_runtime_dependency 'faraday', '~> 1.0', '>= 1.0.1'
end
