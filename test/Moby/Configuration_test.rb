# test/Moby/Configuration_test.rb

require_relative '../test_helper'

describe Moby::Configuration do
  let(:url){'https://phishing.example.com/login'}

  describe "defaults" do
    let(:config){Moby::Configuration.new(url: url)}

    it "keeps the url" do
      _(config.url).must_equal(url)
    end

    it "defaults the backend to mechanize" do
      _(config.backend).must_equal(:mechanize)
      _(config.mechanize?).must_equal(true)
      _(config.selenium?).must_equal(false)
    end

    it "defaults the browser to chrome" do
      _(config.browser).must_equal(:chrome)
    end

    it "defaults form_number to 0" do
      _(config.form_number).must_equal(0)
    end

    it "defaults the field names to username and password" do
      _(config.username_field_name).must_equal('username')
      _(config.password_field_name).must_equal('password')
    end

    it "defaults the field numbers to 0 and 1" do
      _(config.username_field_number).must_equal(0)
      _(config.password_field_number).must_equal(1)
    end

    it "runs indefinitely by default" do
      _(config.iterations).must_be_nil
      _(config.fixed_number_of_submissions?).must_equal(false)
    end

    it "defaults the delay to 0" do
      _(config.delay).must_equal(0)
    end

    it "is not prefilled, email, verbose or debug by default" do
      _(config.username_prefilled?).must_equal(false)
      _(config.username_is_email_address?).must_equal(false)
      _(config.verbose?).must_equal(false)
      _(config.debug?).must_equal(false)
    end
  end

  describe "backend and browser selection" do
    it "selects selenium" do
      _(Moby::Configuration.new(url: url, backend: :selenium).selenium?).must_equal(true)
    end

    it "coerces a string backend to a symbol" do
      _(Moby::Configuration.new(url: url, backend: 'selenium').backend).must_equal(:selenium)
    end

    it "falls back to mechanize when the backend is nil" do
      _(Moby::Configuration.new(url: url, backend: nil).backend).must_equal(:mechanize)
    end

    it "falls back to chrome when the browser is nil" do
      _(Moby::Configuration.new(url: url, browser: nil).browser).must_equal(:chrome)
    end
  end

  describe "coercion of string inputs" do
    let(:config) do
      Moby::Configuration.new(
        url: url,
        form_number: '2',
        username_field_number: '3',
        password_field_number: '4',
        delay: '5',
        iterations: '6'
      )
    end

    it "coerces the numeric switches to integers" do
      _(config.form_number).must_equal(2)
      _(config.username_field_number).must_equal(3)
      _(config.password_field_number).must_equal(4)
      _(config.delay).must_equal(5)
      _(config.iterations).must_equal(6)
    end

    it "treats a given iterations count as a fixed number of submissions" do
      _(config.fixed_number_of_submissions?).must_equal(true)
    end
  end

  describe "#username_is_email_address?" do
    it "is true when set explicitly" do
      _(Moby::Configuration.new(url: url, username_is_email_address: true).username_is_email_address?).must_equal(true)
    end

    it "is truthy when a username hostname is given" do
      _(Moby::Configuration.new(url: url, username_hostname: 'example.com').username_is_email_address?).wont_equal(false)
    end

    it "is truthy when the username field is named email" do
      _(Moby::Configuration.new(url: url, username_field_name: 'email').username_is_email_address?).wont_equal(false)
    end
  end

  describe "#user_agent" do
    it "returns a random agent when not set" do
      agent = Moby::Configuration.new(url: url).user_agent
      _(agent).must_be_kind_of(String)
      _(agent).wont_equal('Mechanize')
    end

    it "returns the set agent" do
      _(Moby::Configuration.new(url: url, user_agent: 'CustomAgent').user_agent).must_equal('CustomAgent')
    end
  end

  describe "#using_form_name?" do
    it "is false without a form name" do
      _(Moby::Configuration.new(url: url).using_form_name?).must_equal(false)
    end

    it "is true with a form name" do
      _(Moby::Configuration.new(url: url, form_name: 'login').using_form_name?).must_equal(true)
    end
  end

  describe "#word_list_path" do
    it "defaults to /usr/share/dict/words" do
      _(Moby::Configuration.new(url: url).word_list_path).must_equal('/usr/share/dict/words')
    end

    it "returns the given path" do
      _(Moby::Configuration.new(url: url, word_list_path: '/tmp/words').word_list_path).must_equal('/tmp/words')
    end
  end
end
