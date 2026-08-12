# test/gemspec_test.rb

require_relative './test_helper'

describe 'moby.rb.gemspec' do
  let(:spec){Gem::Specification.load(File.expand_path('../moby.rb.gemspec', __dir__))}

  it "is a valid specification" do
    _(spec.validate).must_equal(true)
  end

  it "does not pin a date" do
    _(spec.date).must_equal(Gem::Specification.new.date)
  end

  it "takes its version from Moby::VERSION" do
    _(spec.version.to_s).must_equal(Moby::VERSION)
  end

  it "declares its runtime dependencies" do
    _(spec.runtime_dependencies.map(&:name).sort).must_equal(%w{mechanize selenium-webdriver switches.rb})
  end

  it "declares its development dependencies" do
    _(spec.development_dependencies.map(&:name).sort).must_equal(%w{minitest minitest-spec-context rake webmock})
  end
end
