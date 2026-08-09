# test/moby_test.rb

require_relative './test_helper'

describe Moby do
  let(:url){'https://phishing.example.com/login'}

  it "selects the mechanize backend by default" do
    _(Moby.new(url: url).send(:backend)).must_be_instance_of(Moby::Backends::MechanizeBackend)
  end

  it "selects the selenium backend when configured" do
    _(Moby.new(url: url, backend: :selenium).send(:backend)).must_be_instance_of(Moby::Backends::SeleniumBackend)
  end

  it "responds to counter_phish" do
    _(Moby.new(url: url)).must_respond_to(:counter_phish)
  end
end
