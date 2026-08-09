# test/Moby/Backends/SeleniumBackend_test.rb

require_relative '../../test_helper'

describe Moby::Backends::SeleniumBackend do
  let(:url){'https://phishing.example.com/login'}
  let(:generator){Moby::RandomInputGenerator.new(word_list_path: TestFixtures::WORD_LIST_PATH)}

  def backend(**config_args)
    config = Moby::Configuration.new(url: url, backend: :selenium, **config_args)
    Moby::Backends::SeleniumBackend.new(config: config, random_input_generator: generator)
  end

  # Stub the real browser launch so no Chrome/Firefox process is started.
  def with_stubbed_driver
    built = 0
    fake_driver = Object.new
    original = Selenium::WebDriver.method(:for)
    Selenium::WebDriver.define_singleton_method(:for) do |*_args, **_kwargs|
      built += 1
      fake_driver
    end
    begin
      yield(fake_driver, ->{built})
    ensure
      Selenium::WebDriver.define_singleton_method(:for, original)
    end
  end

  describe "#driver" do
    it "builds the driver once and memoises it (returning a non-nil driver)" do
      with_stubbed_driver do |fake_driver, build_count|
        b = backend
        first = b.send(:driver)
        second = b.send(:driver)

        _(first).wont_be_nil
        _(first).must_be_same_as(fake_driver)
        _(first).must_be_same_as(second)
        _(build_count.call).must_equal(1)
      end
    end
  end
end
