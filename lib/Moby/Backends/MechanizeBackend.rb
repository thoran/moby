# lib/moby/backends/mechanize_backend.rb
# Moby::Backends::MechanizeBackend

require 'mechanize'
require 'pp'

class Moby
  module Backends
    class MechanizeBackend
      def counter_phish
        set_up_agent
        load_page
        repeatedly_fill_and_submit_login_form
      end

      private

      def initialize(config:, random_input_generator:)
        @config = config
        @random_input_generator = random_input_generator
      end

      def agent
        @agent ||= (
          puts "Setting up Mechanize agent..." if @config.verbose?
          agent = Mechanize.new
          puts "Agent setup complete." if @config.verbose?
          agent
        )
      end
      alias_method :set_up_agent, :agent

      def page
        @page ||= (
          puts "Navigating to #{@config.url}..." if @config.verbose?
          page = agent.get(@config.url)
          puts "Page loaded successfully." if @config.verbose?
          page
        )
      end
      alias_method :load_page, :page

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
              puts "Iteration #{submission_count} of #{@config.iterations}." if @config.verbose?
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
        agent.user_agent_alias = @config.user_agent
        username_field.value = username unless @config.username_prefilled?
        password_field.value = password
        pp page if @config.debug?
        result = agent.submit(form)
        pp result if @config.debug?
        sleep @config.delay if @config.delay > 0
      rescue Net::HTTP::Persistent::Error
        puts "\n\nNet::HTTP::Persistent::Error rescued.\n\n" if @config.verbose?
      rescue Net::OpenTimeout
        puts "\n\nNet::OpenTimeout rescued.\n\n" if @config.verbose?
      end

      def find_form_by_name
        page.form_with(name: @config.form_name) ||
          page.form_with(id: @config.form_name) ||
          raise("Could not find a form with the name or id of #{@config.form_name}.")
      end

      def find_form_by_number
        page.forms[@config.form_number] ||
          raise("Could not find a form at index #{@config.form_number}.")
      end

      def username
        @random_input_generator.random_username
      end

      def password
        @random_input_generator.random_password
      end

      def username_field
        @username_field ||=(
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
        form.field_with(name: @config.username_field_name) ||
          form.field_with(id: @config.username_field_name) ||
          raise("Could not find username field: #{@config.username_field_name}")
      end

      def find_username_field_by_number
        form.fields[@config.username_field_number] ||
          raise("Could not find username field at index #{@config.username_field_number}")
      end

      def find_password_field_by_name
        form.field_with(name: @config.password_field_name) ||
          form.field_with(id: @config.password_field_name) ||
          raise("Could not find password field: #{@config.password_field_name}.")
      end

      def find_password_field_by_number
        form.fields[@config.password_field_number] ||
          raise("Could not find password field at index: #{@config.password_field_number}.")
      end
    end
  end
end
