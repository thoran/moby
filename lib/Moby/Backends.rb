# lib/Moby/Backends.rb
# Moby::Backends

require_relative './Backends/MechanizeBackend'
require_relative './Backends/SeleniumBackend'

class Moby
  module Backends
    def self.for(config:, random_input_generator:)
      case config.backend
      when :mechanize
        MechanizeBackend.new(config: config, random_input_generator: random_input_generator)
      when :selenium
        SeleniumBackend.new(config: config, random_input_generator: random_input_generator)
      else
        raise "Unknown backend: #{config.backend.inspect}."
      end
    end
  end
end
