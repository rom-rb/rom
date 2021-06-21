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
      auto_registration.relations.each { |r| register_relation(r) }
      auto_registration.commands.each { |r| register_command(r) }
      auto_registration.mappers.each { |r| register_mapper(r) }
      self
    end

    # @api public
    def relation_classes
      components.relations.map(&:constant)
    end

    # @api public
    def command_classes
      components.commands.map(&:constant)
    end

    # @api public
    def mapper_classes
      components.mappers.map(&:constant)
    end
  end
end
