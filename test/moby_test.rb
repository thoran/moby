# test/moby_test.rb

require_relative './test_helper'

describe Moby do
  let(:url){'https://phishing.example.com/login'}
  let(:moby){Moby.new(url: url)}

  before do
    WebMock.disable_net_connect!

    # Stub the login page
    stub_request(:get, url)
      .to_return(
        status: 200,
        body: TestFixtures::SIMPLE_LOGIN_FORM,
        headers: {'Content-Type' => 'text/html'}
      )

    # Stub form submission
    stub_request(:post, 'https://phishing.example.com/login')
      .to_return(status: 200, body: 'Success')
  end

  after do
    WebMock.reset!
    WebMock.allow_net_connect!
  end

  describe "initialization" do
    it "accepts url parameter" do
      _(moby.url).must_equal(url)
    end

    it "sets default form_number to 0" do
      _(moby.form_number).must_equal(0)
    end

    it "sets default username_field_name to 'username'" do
      _(moby.username_field_name).must_equal('username')
    end

    it "sets default password_field_name to 'password'" do
      _(moby.password_field_name).must_equal('password')
    end

    it "sets default username_field_number to 0" do
      _(moby.username_field_number).must_equal(0)
    end

    it "sets default password_field_number to 1" do
      _(moby.password_field_number).must_equal(1)
    end

    it "accepts form_name parameter" do
      m = Moby.new(url: url, form_name: 'login')

      _(m.form_name).must_equal('login')
    end

    it "accepts username_hostname parameter" do
      m = Moby.new(url: url, username_hostname: 'example.com')

      _(m.username_hostname).must_equal('example.com')
    end

    it "accepts username_is_email_address parameter" do
      m = Moby.new(url: url, username_is_email_address: true)

      _(m.username_is_email_address).must_equal(true)
    end
  end

  describe "mechanize setup" do
    it "creates Mechanize instance lazily" do
      mech = moby.instance_variable_get(:@mechanize)

      _(mech).must_be_nil

      moby.send(:mechanize)
      mech = moby.instance_variable_get(:@mechanize)

      _(mech).must_be_instance_of(Mechanize)
    end

    it "reuses same mechanize instance" do
      mech1 = moby.send(:mechanize)
      mech2 = moby.send(:mechanize)

      _(mech1).must_be_same_as(mech2)
    end
  end

  describe "page loading" do
    it "loads the target URL" do
      page = moby.send(:page)

      _(page).must_be_instance_of(Mechanize::Page)
      assert_requested(:get, url, times: 1)
    end

    it "reuses loaded page" do
      page1 = moby.send(:page)
      page2 = moby.send(:page)

      _(page1).must_be_same_as(page2)
      assert_requested(:get, url, times: 1)
    end

    it "handles meta refresh redirects" do
      redirect_body = '<html><head><meta http-equiv="Refresh" content="0; url=https://phishing.example.com/real-login"></head></html>'

      stub_request(:get, url)
        .to_return(status: 200, body: redirect_body, headers: {'Content-Type' => 'text/html'})

      stub_request(:get, 'https://phishing.example.com/real-login')
        .to_return(status: 200, body: TestFixtures::SIMPLE_LOGIN_FORM, headers: {'Content-Type' => 'text/html'})

      m = Moby.new(url: url)
      page = m.send(:page)

      assert_requested(:get, url, times: 1)
      assert_requested(:get, 'https://phishing.example.com/real-login', times: 1)
    end
  end

  describe "form finding" do
    describe "finding by name" do
      let(:moby) do
        Moby.new(url: url, form_name: 'login')
      end

      it "finds form by name when form_name is set" do
        moby.send(:page)
        form = moby.send(:form)

        _(form).must_be_instance_of(Mechanize::Form)
        _(form.name).must_equal('login')
      end
    end

    describe "finding by number" do
      let(:moby) do
        Moby.new(url: 'https://multi.example.com/page', form_number: 1)
      end

      it "finds form by number when form_number is set" do
        stub_request(:get, 'https://multi.example.com/page')
          .to_return(
            status: 200,
            body: TestFixtures::MULTIPLE_FORMS,
            headers: {'Content-Type' => 'text/html'}
          )
        moby.send(:page)
        form = moby.send(:form)

        _(form).must_be_instance_of(Mechanize::Form)
        _(form.node['id']).must_equal('login_form')
      end
    end

    describe "deafult form" do
      it "defaults to first form" do
        moby.send(:page)
        form = moby.send(:form)

        _(form).must_be_instance_of(Mechanize::Form)
      end
    end
  end

  describe "field finding" do
    describe "finding by name" do
      let(:moby) do
        Moby.new(url: url, form_name: 'login', username_field_name: 'username', password_field_name: 'password')
      end

      it "finds username field by name" do
        moby.send(:page)
        moby.send(:form)
        field = moby.send(:username_field)

        _(field.name).must_equal('username')
      end

      it "finds password field by name" do
        moby.send(:page)
        moby.send(:form)
        field = moby.send(:password_field)

        _(field.name).must_equal('password')
      end
    end

    describe "finding by number" do
      let(:moby) do
        Moby.new(url: url, username_field_number: 0, password_field_number: 1)
      end

      it "finds username field by number" do
        moby.send(:page)
        moby.send(:form)
        field = moby.send(:username_field)

        _(field).wont_be_nil
      end

      it "finds password field by number" do
        moby.send(:page)
        moby.send(:form)
        field = moby.send(:password_field)

        _(field).wont_be_nil
      end
    end
  end

  describe "#username" do
    it "generates random username" do
      username = moby.send(:username)

      _(username).must_be_kind_of(String)
      _(username.length).must_be(:>, 0)
    end

    it "generates email address when username_is_email_address is true" do
      m = Moby.new(url: url, username_is_email_address: true)
      username = m.send(:username)

      _(username).must_match(/@/)
    end

    it "generates email with custom hostname" do
      m = Moby.new(url: url, username_hostname: 'example.com')
      username = m.send(:username)

      _(username).must_match(/@example\.com$/)
    end


    it "generates different usernames" do
      usernames = 10.times.map{moby.send(:username)}

      _(usernames.uniq.length).must_be(:>, 1)
    end
  end

  describe "#password" do
    it "generates random password" do
      password = moby.send(:password)

      _(password).must_be_kind_of(String)
      _(password.length).must_be(:>, 0)
    end
  end

  describe "#user_agent" do
    it "returns random user agent when not set" do
      agent = moby.send(:user_agent)

      _(agent).must_be_kind_of(String)
      _(agent).wont_equal('Mechanize')
    end

    it "returns set user agent when provided" do
      m = Moby.new(url: url, user_agent: 'CustomAgent')

      _(m.send(:user_agent)).must_equal('CustomAgent')
    end

    it "generates different random agents" do
      agents = 10.times.map{Moby.new(url: url).send(:user_agent)}

      _(agents.uniq.length).must_be(:>, 1)
    end
  end

  describe "#username_is_email_address?" do
    it "returns true when username_is_email_address is set" do
      m = Moby.new(url: url, username_is_email_address: true)

      _(m.send(:username_is_email_address?)).must_equal(true)
    end

    it "returns true when username_hostname is set" do
      m = Moby.new(url: url, username_hostname: 'example.com')

      _(m.send(:username_is_email_address?)).wont_be_nil
    end

    it "returns false by default" do
      _(moby.send(:username_field_name)).must_equal('username')
    end
  end
end
