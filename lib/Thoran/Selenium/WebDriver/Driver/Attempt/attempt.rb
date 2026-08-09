# Thoran/Selenium/WebDriver/Attempt/attempt.rb
# Thoran::Selenium::WebDriver::Attempt.attempt

# 20200419
# 0.0.1

# Examples:
# 1. driver.attempt do |driver|
#   driver.get('https://example.com/users/sign_in')
#   enter_username
#   enter_password
#   sign_in
# end

# Changes:
# 1. + Thoran namespace.

module Thoran
  module Selenium
    module WebDriver
      module Driver
        module Attempt

          def attempt(max_attempts = 3, &block)
            attempts = 0
            loop do
              begin
                yield
                break
              rescue Timeout::Error, ::Selenium::WebDriver::Error::UnknownError, ::Selenium::WebDriver::Error::NoSuchElementError => e
                attempts += 1
                if attempts >= max_attempts
                  @driver.quit
                  puts "Giving up after #{max_attempts} attempts to #{__method__} because #{e}."
                  exit
                end
              end
            end
          end

        end
      end
    end
  end
end

module Selenium
  module WebDriver
    class Driver
      include Thoran::Selenium::WebDriver::Driver::Attempt
    end
  end
end
