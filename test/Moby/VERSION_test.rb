# test/Moby/VERSION_test.rb

require_relative '../test_helper'

describe Moby do
  describe "VERSION" do
    it "has VERSION constant" do
      _(defined?(Moby::VERSION)).wont_be_nil
    end

    it "version is a string" do
      _(Moby::VERSION).must_be_kind_of(String)
    end

    it "version follows semver pattern" do
      _(Moby::VERSION).must_match(/\d+\.\d+\.\d+/)
    end

    it "version is 1.0.0" do
      _(Moby::VERSION).must_equal('1.0.0')
    end
  end
end
