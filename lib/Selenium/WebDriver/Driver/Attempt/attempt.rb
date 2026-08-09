# Selenium/WebDriver/Driver/Attempt/attempt.rb
# Selenium::WebDriver::Driver::Attempt.attempt

# 20200418
# 0.3.0

# Examples:
# 1. driver.attempt do |driver|
#     driver.get('https://example.com/users/sign_in')
#     enter_username
#     enter_password
#     sign_in
#   end

# Changes:
# 1. Moved all the logic into the Thoran namespace.

require 'Thoran/Selenium/WebDriver/Driver/Attempt/attempt'
