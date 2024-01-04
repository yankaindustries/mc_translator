# frozen_string_literal: true

require_relative 'lib/mc_translator/version'

Gem::Specification.new do |spec|
  spec.name          = 'mc_translator'
  spec.version       = McTranslator::VERSION
  spec.authors       = ['justinjones53@gmail.com']
  spec.email         = ['justinjones53@gmail.com']

  spec.summary       = 'Translates locale files'
  spec.description   = 'Translates locale files'
  spec.homepage      = 'http://github.com/yankaindustries/mc_translator'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  # spec.metadata['allowed_push_host'] = 'http://mygemserver.com'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'http://github.com/yankaindustries/mc_translator'
  spec.metadata['changelog_uri'] = 'http://github.com/yankaindustries/mc_translator'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'git', '>= 1.11', '< 1.20'
  spec.add_dependency 'yaml', '~> 0.1.1'
  spec.add_dependency 'smartling', '~> 2.0.3'
  spec.add_dependency 'dotenv'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
