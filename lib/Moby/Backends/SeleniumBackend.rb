# lib/Moby/Backends/SeleniumBackend.rb
# Moby::Backends::SeleniumBackend

require 'selenium-webdriver'

require_relative '../../Selenium/WebDriver/Driver/Attempt/attempt'
require_relative '../../Selenium/WebDriver/SearchContext/ElementPresentQ/element_presentQ'

class Moby
  module Backends
    class SeleniumBackend
      def counter_phish
        set_up_driver
        navigate_to_target
        repeatedly_fill_and_submit_login_form
      ensure
        cleanup_driver unless @config.debug?
      end

      private

      def initialize(config:, random_input_generator:)
        @config = config
        @random_input_generator = random_input_generator
        @driver = nil
      end

      def driver
        @driver ||= (
          puts "Setting up #{@config.browser} driver..." if @config.verbose
          driver =
            case @config.browser.to_sym
            when :chrome
              options = Selenium::WebDriver::Chrome::Options.new
              options.add_argument('--headless') unless @config.debug
              options.add_argument('--disable-gpu')
              options.add_argument('--no-sandbox')
              options.add_argument("user-agent=#{@config.user_agent}") if @config.user_agent
              Selenium::WebDriver.for(:chrome, options: options)
            when :firefox
              options = Selenium::WebDriver::Firefox::Options.new
              options.add_argument('--headless') unless @config.debug
              options.add_preference('general.useragent.override', @config.user_agent) if @config.user_agent
              Selenium::WebDriver.for(:firefox, options: options)
            else
              Selenium::WebDriver.for(@config.browser)
            end
          puts "Driver setup complete." if @config.verbose?
          driver
        )
      end
      alias_method :set_up_driver, :driver

      def navigate_to_target
        puts "Navigating to #{@config.url}..." if @config.verbose?
        @driver.attempt do
          @driver.get(@config.url)
          wait_for_page_load
        end
        puts "Page loaded successfully." if @config.verbose?
      end

      def wait_for_page_load
        wait = Selenium::WebDriver::Wait.new(timeout: 10)
        wait.until do
          @driver.execute_script('return document.readyState') == 'complete'
        end
      end

      def form
        @form ||= (
          if @config.using_form_name?
            find_form_by_name
          else
            find_form_by_number
          end
        )
      end

      def repeatedly_fill_and_submit_login_form
        start_time = Time.now
        puts "moby session begun #{start_time}."
        submission_count = 0
        begin
          if @config.fixed_number_of_submissions?
            @config.iterations.times do |iteration|
              fill_and_submit_login_form
              submission_count += 1
              puts "Submission #{submission_count} of #{@config.iterations}." if @config.verbose?
            end
            puts "Successfully completed #{@config.iterations} submissions." if @config.verbose?
          else
            loop do
              fill_and_submit_login_form
              submission_count += 1
              puts "#{submission_count} #{username}:#{password}" if @config.verbose?
            end
          end
        ensure
          finish_time = Time.now
          time_delta_in_minutes = (finish_time - start_time) / 60
          submissions_per_minute = submission_count / time_delta_in_minutes
          puts "moby session terminated #{finish_time} with #{submission_count} counter-phishes served in #{time_delta_in_minutes} minutes for an average of #{submissions_per_minute} submissions per minute."
        end
      end

      def fill_and_submit_login_form
        puts "Filling with: #{username}:#{password}" if @config.verbose?
        driver.navigate.to(@config.url)
        wait_for_page_load
        driver.attempt do
          unless @config.username_prefilled?
            username_field.clear
            username_field.send_keys(username)
          end
          password_field.clear
          password_field.send_keys(password)
          submit_form(form)
        end
        sleep @config.delay if @config.delay > 0
      end

      def find_form_by_name
        name = @config.form_name
        selectors = [
          [:name, name],
          [:id, name],
          [:css, "form[name='#{name}']"],
          [:css, "form##{name}"]
        ]
        selectors.each do |type, selector|
          if @driver.element_present?(type, selector)
            return @driver.find_element(type, selector)
          end
        end
        raise("Could not find a form with the name or id of #{@config.form_name}.")
      end

      def find_form_by_number
        index = @config.form_number
        forms = @driver.find_elements(:tag_name, 'form')
        return forms[index] if forms[index]
        raise("Could not find a form at index #{@config.form_number}.")
      end

      def username
        @random_input_generator.random_username
      end

      def password
        @random_input_generator.random_password
      end

      def username_field
        @username_field ||= (
          if @config.using_username_field_name?
            find_username_field_by_name
          else
            find_username_field_by_number
          end
        )
      end

      def password_field
        @password_field ||= (
          if @config.using_password_field_name?
            find_password_field_by_name
          else
            find_password_field_by_number
          end
        )
      end

      def find_username_field_by_name
        name = @config.username_field_name
        selectors = [
          [:name, name],
          [:id, name],
          [:css, "input[name='#{name}']"],
          [:css, "input##{name}"]
        ]
        selectors.each do |type, selector|
          begin
            element = form.find_element(type, selector)
            return element if element
          rescue Selenium::WebDriver::Error::NoSuchElementError
            next
          end
        end
        raise("Could not find username field: #{@config.username_field_name}")
      end

      def find_username_field_by_number
        index = @config.username_field_number
        inputs = form.find_elements(:tag_name, 'input')
        inputs[index] ||
          raise("Could not find username field at index #{index}")
      end

      def find_password_field_by_name
        name = @config.password_field_name
        selectors = [
          [:name, name],
          [:id, name],
          [:css, "input[name='#{name}']"],
          [:css, "input##{name}"]
        ]
        selectors.each do |type, selector|
          begin
            element = form.find_element(type, selector)
            return element if element
          rescue Selenium::WebDriver::Error::NoSuchElementError
            next
          end
        end
        raise("Could not find password field: #{@config.password_field_name}")
      end

      def find_password_field_by_number
        index = @config.password_field_number
        inputs = form.find_elements(:tag_name, 'input')
        inputs[index] ||
          raise("Could not find password field at index #{index}")
      end

      def submit_form(form)
        begin
          submit_button = form.find_element(:css, "input[type='submit'], button[type='submit'], button")
          submit_button.click
        rescue
          form.submit
        end
        sleep 0.5
      end

      def cleanup_driver
        @driver.quit if @driver
        puts "Driver closed." if @config.verbose?
      end
    end
  end
end
