# lib/Moby/Configuration.rb
# Moby::Configuration

require 'mechanize'

class Moby
  class Configuration
    AVAILABLE_USER_AGENTS = (Mechanize::AGENT_ALIASES.keys - ['Mechanize']).freeze

    attr_accessor(
      :url,
      :backend,
      :browser,
      :debug,
      :verbose,
      :form_name,
      :form_number,
      :username_field_name,
      :username_field_number,
      :password_field_name,
      :password_field_number,
      :username_hostname,
      :username_is_email_address,
      :username_prefilled,
      :iterations,
      :delay,
      :word_list_path
    )

    attr_writer(
      :user_agent,
    )

    def user_agent
      @user_agent || random_user_agent
    end

    def using_form_name?
      !@form_name.nil?
    end

    def using_username_field_name?
      !@username_field_name.nil?
    end

    def using_password_field_name?
      !@password_field_name.nil?
    end

    def mechanize?
      @backend == :mechanize
    end

    def selenium?
      @backend == :selenium
    end

    def username_is_email_address?
      @username_is_email_address || @username_hostname || @username_field_name == 'email'
    end

    def username_prefilled?
      @username_prefilled
    end

    def debug?
      @debug
    end

    def verbose?
      @verbose
    end

    def fixed_number_of_submissions?
      !!@iterations
    end

    private

    # @param url [String] The target URL
    # @param backend [Symbol] :mechanize or :selenium (default: :mechanize)
    # @param browser [Symbol] :chrome or :firefox (default: :chrome)

    def initialize(url:, backend: :mechanize, browser: :chrome, **args)
      @url = url
      @backend = (backend || :mechanize).to_sym

      # Browser configuration (for Selenium)
      @browser = (browser || :chrome).to_sym
      @user_agent = args[:user_agent]

      # Form identification
      @form_name = args[:form_name]
      @form_number = (args[:form_number] || 0).to_i

      # Field identification
      @username_field_name = args[:username_field_name] || 'username'
      @username_field_number = (args[:username_field_number] || 0).to_i
      @password_field_name = args[:password_field_name] || 'password'
      @password_field_number = (args[:password_field_number] || 1).to_i

      # Username configuration
      @username_hostname = args[:username_hostname]
      @username_is_email_address = args[:username_is_email_address] || false
      @username_prefilled = args[:username_prefilled] || false

      # Runtime configuration
      @debug = args[:debug] || false
      @verbose = args[:verbose] || false
      @iterations = args[:iterations] && args[:iterations].to_i
      @delay = (args[:delay] || 0).to_i
      @word_list_path = args[:word_list_path] || '/usr/share/dict/words'
    end

    def random_user_agent
      AVAILABLE_USER_AGENTS.sample
    end
  end
end
