# lib/Moby/RandomInputGenerator.rb
# Moby::RandomInputGenerator

class Moby
  class RandomInputGenerator
    TLD = %w{com net org edu int mil gov arpa biz aero name coop info pro museum}

    def random_username
      if username_is_email_address?
        if @username_hostname
          "#{random_word}@#{@username_hostname}"
        else
          "#{random_word}@#{random_word}.#{random_TLD}"
        end
      else
        random_word
      end
    end

    def random_password
      random_word
    end

    private

    def initialize(word_list_path:, username_hostname: nil, username_is_email_address: false)
      @word_list_path = word_list_path
      @username_hostname = username_hostname
      @username_is_email_address = username_is_email_address
    end

    def random_word
      words.sample
    end

    def words
      @words ||= File.readlines(@word_list_path).map(&:chomp).reject(&:empty?)
    end
    alias_method :load_words, :words

    def random_TLD
      TLD.sample
    end

    def username_is_email_address?
      @username_is_email_address
    end
  end
end
