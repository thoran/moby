# test/Moby/VERSION_test.rb

require_relative '../test_helper'

describe Moby do
  describe "VERSION" do
    it "is a string" do
      _(Moby::VERSION).must_be_instance_of String
    end

    it "is three numbers separated by dots" do
      _(Moby::VERSION).must_match(/\A\d+\.\d+\.\d+\z/)
    end

    it "matches the newest entry in the CHANGELOG" do
      changelog = File.read(File.expand_path('../../CHANGELOG', __dir__))
      _(changelog[/^(\d+\.\d+\.\d+):/, 1]).must_equal Moby::VERSION
    end
  end
end
