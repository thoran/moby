# test/Moby/Backends_test.rb

require_relative '../test_helper'

describe Moby::Backends do
  let(:url){'https://phishing.example.com/login'}
  let(:generator){Moby::RandomInputGenerator.new(word_list_path: TestFixtures::WORD_LIST_PATH)}

  def backend_for(**config_args)
    config = Moby::Configuration.new(url: url, **config_args)
    Moby::Backends.for(config: config, random_input_generator: generator)
  end

  describe ".for" do
    it "returns a MechanizeBackend for the mechanize configuration" do
      _(backend_for).must_be_instance_of(Moby::Backends::MechanizeBackend)
    end

    it "returns a SeleniumBackend for the selenium configuration" do
      _(backend_for(backend: :selenium)).must_be_instance_of(Moby::Backends::SeleniumBackend)
    end

    it "raises for an unknown backend" do
      _(proc{backend_for(backend: :ftp)}).must_raise(RuntimeError)
    end
  end
end
