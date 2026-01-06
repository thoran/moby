# moby.gemspec

require_relative './lib/Moby/VERSION'

Gem::Specification.new do |spec|
  spec.name = 'moby.rb'

  spec.version = Moby::VERSION
  spec.date = '2026-01-08'

  spec.summary = "Moby is a credentials poisoning tool which floods phishing forms with fake credentials."
  spec.description = "Sometimes when they go fishing, they get a whale and it sinks their boat. Moby is a counter-phishing tool that floods phishing websites with fake login credentials, making harvested data useless."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'https://github.com/thoran/moby'
  spec.license = 'MIT'

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency('mechanize', '~> 2')
  spec.add_dependency('switches.rb', '~> 0')

  spec.add_development_dependency('minitest')
  spec.add_development_dependency('minitest-spec-context')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('webmock')

  spec.files = Dir[
    'bin/*',
    'lib/**/*.rb',
    'test/**/*.rb',
    'CHANGES.txt',
    'Gemfile',
    'LICENSE.txt',
    'moby.gemspec',
    'Rakefile',
    'README.md',
  ]

  spec.bindir = 'bin'
  spec.executables = ['moby']
  spec.require_paths = ['lib']

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/thoran/moby/issues",
    "changelog_uri" => "https://github.com/thoran/moby/blob/main/CHANGES.txt",
    "source_code_uri" => "https://github.com/thoran/moby",
    "documentation_uri" => "https://github.com/thoran/moby/blob/main/README.md"
  }
end
