# frozen_string_literal: true

require_relative "compat/setup"

module ROM
  class Configuration
    def_delegators :@setup, :auto_registration
  end
end
