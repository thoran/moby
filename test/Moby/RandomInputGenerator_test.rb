# test/Moby/RandomInputGenerator_test.rb

require_relative '../test_helper'

describe Moby::RandomInputGenerator do
  let(:word_list_path){TestFixtures::WORD_LIST_PATH}

  def generator(**args)
    Moby::RandomInputGenerator.new(word_list_path: word_list_path, **args)
  end

  describe "#random_username" do
    it "returns a word from the list by default" do
      _(TestFixtures::WORDS).must_include(generator.random_username)
    end

    it "returns an email address when username_is_email_address is true" do
      _(generator(username_is_email_address: true).random_username).must_match(/\A[^@]+@[^@]+\z/)
    end

    it "uses the given hostname for the email address" do
      username = generator(username_hostname: 'example.com', username_is_email_address: true).random_username
      _(username).must_match(/@example\.com\z/)
    end

    it "generates more than one distinct username" do
      usernames = 20.times.map{generator.random_username}
      _(usernames.uniq.length).must_be(:>, 1)
    end
  end

  describe "#random_password" do
    it "returns a word from the list" do
      _(TestFixtures::WORDS).must_include(generator.random_password)
    end
  end
end
