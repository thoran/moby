# Moby.rb
# Moby

require_relative './Moby/VERSION'
require_relative './Moby/Configuration'
require_relative './Moby/RandomInputGenerator'
require_relative './Moby/Backends'

class Moby
  def counter_phish
    backend.counter_phish
  end

  private

  def initialize(**args)
    @configuration = Configuration.new(**args)
  end

  def backend
    @backend ||= Backends.for(
      config: @configuration,
      random_input_generator: random_input_generator
    )
  end

  def random_input_generator
    @random_input_generator ||= RandomInputGenerator.new(
      word_list_path: @configuration.word_list_path,
      username_hostname: @configuration.username_hostname,
      username_is_email_address: @configuration.username_is_email_address?
    )
  end
end
