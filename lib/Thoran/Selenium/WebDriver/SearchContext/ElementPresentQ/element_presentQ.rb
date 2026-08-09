# Thoran/Selenium/WebDriver/SearchContext/ElementPresentQ/element_presentQ.rb
# Thoran::Selenium::WebDriver::SearchContext::ElementPresentQ.element_present?

# 20200418
# 0.0.0

# Examples:
# 1. driver.element_present?(:xpath, '//a[@id="submit"]')
# 2. driver.element_present?(:id, @logout_button_id)

# Changes:
# 1. + Thoran namespace.

module Thoran
  module Selenium
    module WebDriver
      module SearchContext
        module ElementPresentQ

          def element_present?(selector_type, selector)
            bridge.find_element_by(selector_type, selector)
            true
          rescue ::Selenium::WebDriver::Error::NoSuchElementError
            false
          end

        end
      end
    end
  end
end

module Selenium
  module WebDriver
    class Driver
      include Thoran::Selenium::WebDriver::SearchContext::ElementPresentQ
    end
  end
end
