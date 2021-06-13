# frozen_string_literal: true

require_relative "auto_registration"

module ROM
  # Setup objects collect component classes during setup/finalization process
  #
  # @api public
  class Setup
    # Enable auto-registration for a given setup object
    #
    # @param [String, Pathname] directory The root path to components
    # @param [Hash] options
    # @option options [Boolean, String] :namespace Toggle root namespace
    #                                              or provide a custom namespace name
    #
    # @return [Setup]
    #
    # @deprecated
    #
    # @api public
    def auto_registration(directory, **options)
      auto_registration = AutoRegistration.new(directory, inflector: inflector, **options)
      auto_registration.relations.map { |r| register_relation(r) }
      auto_registration.commands.map { |r| register_command(r) }
      auto_registration.mappers.map { |r| register_mapper(r) }
      self
    end
  end
end
