# frozen_string_literal: true

require 'rom/setup/auto_registration'

module ROM
  # Setup objects collect component classes during setup/finalization process
  #
  # @api public
  class Setup
    # @return [Array] registered relation subclasses
    #
    # @api private
    attr_reader :relation_classes

    # @return [Array] registered mapper subclasses
    #
    # @api private
    attr_reader :mapper_classes

    # @return [Array] registered command subclasses
    #
    # @api private
    attr_reader :command_classes

    # @api private
    attr_reader :plugins

    # @api private
    attr_reader :notifications

    # @api private
    def initialize(notifications)
      @relation_classes = []
      @command_classes = []
      @mapper_classes = []
      @plugins = []
      @notifications = notifications
    end

    # Enable auto-registration for a given setup object
    #
    # @param [String, Pathname] directory The root path to components
    # @param [Hash] options
    # @option options [Boolean, String] :namespace Enable/disable namespace or provide a custom namespace name
    #
    # @return [Setup]
    #
    # @api public
    def auto_registration(directory, options = {})
      auto_registration = AutoRegistration.new(directory, options)
      auto_registration.relations.map { |r| register_relation(r) }
      auto_registration.commands.map { |r| register_command(r) }
      auto_registration.mappers.map { |r| register_mapper(r) }
      self
    end

    # Relation sub-classes are being registered with this method during setup
    #
    # @api private
    def register_relation(*klasses)
      klasses.reduce(@relation_classes, :<<)
    end

    # Mapper sub-classes are being registered with this method during setup
    #
    # @api private
    def register_mapper(*klasses)
      klasses.reduce(@mapper_classes, :<<)
    end

    # Command sub-classes are being registered with this method during setup
    #
    # @api private
    def register_command(*klasses)
      klasses.reduce(@command_classes, :<<)
    end

    # @api private
    def register_plugin(plugin)
      plugins << plugin
    end
  end
end
