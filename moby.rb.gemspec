# moby.rb.gemspec

require_relative './lib/Moby/VERSION'

class Gem::Specification
  def dependencies=(gems)
    gems.each{|gem| add_dependency(*gem)}
  end

  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'moby.rb'
  spec.version = Moby::VERSION

  spec.summary = "Moby is a credentials poisoning tool which floods phishing forms with fake credentials."
  spec.description = "Sometimes when they go fishing, they get a whale and it sinks their boat. Moby is a counter-phishing tool that floods phishing websites with fake login credentials, making harvested data useless."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'https://github.com/thoran/moby'
  spec.license = 'MIT'

  spec.required_ruby_version = ">= 3.3.0"

  spec.dependencies = [
    ['mechanize', '~> 2'],
    ['selenium-webdriver', '~> 4'],
    ['switches.rb', '~> 0'],
  ]

  spec.development_dependencies = [
    'minitest',
    'minitest-spec-context',
    'rake',
    'webmock'
  ]

  spec.files = [
    Dir['bin/*'],
    Dir['lib/**/*.rb'],
    Dir['test/**/*.rb'],
    'CHANGELOG',
    'Gemfile',
    'LICENSE.txt',
    'moby.rb.gemspec',
    'Rakefile',
    'README.md',
  ].flatten

  spec.bindir = 'bin'
  spec.executables = ['moby']
  spec.require_paths = ['lib']

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/thoran/moby/issues",
    "changelog_uri" => "https://github.com/thoran/moby/blob/main/CHANGELOG",
    "source_code_uri" => "https://github.com/thoran/moby",
    "documentation_uri" => "https://github.com/thoran/moby/blob/main/README.md"
  }
end
