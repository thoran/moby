# test/Moby/Backends/MechanizeBackend_test.rb

require_relative '../../test_helper'

describe Moby::Backends::MechanizeBackend do
  let(:url){'https://phishing.example.com/login'}
  let(:generator){Moby::RandomInputGenerator.new(word_list_path: TestFixtures::WORD_LIST_PATH)}

  def backend(**config_args)
    config = Moby::Configuration.new(url: url, **config_args)
    Moby::Backends::MechanizeBackend.new(config: config, random_input_generator: generator)
  end

  before do
    WebMock.disable_net_connect!
    stub_request(:get, url)
      .to_return(status: 200, body: TestFixtures::SIMPLE_LOGIN_FORM, headers: {'Content-Type' => 'text/html'})
    stub_request(:post, url).to_return(status: 200, body: 'Success')
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect!
  end

  describe "page loading" do
    it "loads the target url once and memoises the page" do
      b = backend
      page1 = b.send(:page)
      page2 = b.send(:page)

      _(page1).must_be_instance_of(Mechanize::Page)
      _(page1).must_be_same_as(page2)
      assert_requested(:get, url, times: 1)
    end
  end

  describe "form finding" do
    it "finds the form by name" do
      form = backend(form_name: 'login').send(:form)

      _(form).must_be_instance_of(Mechanize::Form)
      _(form.name).must_equal('login')
    end

    it "finds the form by number" do
      multi_url = 'https://multi.example.com/page'
      stub_request(:get, multi_url)
        .to_return(status: 200, body: TestFixtures::MULTIPLE_FORMS, headers: {'Content-Type' => 'text/html'})
      config = Moby::Configuration.new(url: multi_url, form_number: 1)
      b = Moby::Backends::MechanizeBackend.new(config: config, random_input_generator: generator)

      _(b.send(:form).node['id']).must_equal('login_form')
    end
  end

  describe "field finding" do
    it "finds the username and password fields by name" do
      b = backend(form_name: 'login', username_field_name: 'username', password_field_name: 'password')

      _(b.send(:username_field).name).must_equal('username')
      _(b.send(:password_field).name).must_equal('password')
    end
  end

  describe "submitting" do
    it "fills both fields and submits" do
      backend.send(:fill_and_submit_login_form)

      assert_requested(:post, url) do |request|
        request.body.match?(/username=[^&]+/) && request.body.match?(/password=[^&]+/)
      end
    end

    it "submits only the password when the username is prefilled" do
      backend(username_prefilled: true).send(:fill_and_submit_login_form)

      assert_requested(:post, url) do |request|
        request.body.match?(/username=(&|\z)/) && request.body.match?(/password=[^&]+/)
      end
    end
  end
end
