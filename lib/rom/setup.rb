# frozen_string_literal: true

require "rom/loader"

module ROM
  # Setup objects collect component classes during setup/finalization process
  #
  # @api public
  class Setup
    # @api private
    attr_reader :plugins

    # @api private
    attr_reader :notifications

    # @api private
    attr_accessor :inflector

    # @api private
    attr_reader :components

    # @api private
    def initialize(notifications)
      @plugins = []
      @notifications = notifications
      @inflector = Inflector
      @components = {relations: [], commands: [], mappers: []}
    end

    # Enable auto-registration for a given setup object
    #
    # @param [String, Pathname] directory The root path to components
    # @param [Hash] options
    # @option options [Boolean] :namespace Toggle root namespace
    #
    # @return [Setup]
    #
    # @api public
    def auto_register(directory, **options)
      @auto_register ||= [directory, {**options}]
    end

    # Relation sub-classes are being registered with this method during setup
    #
    # @api private
    def register_relation(*klasses)
      components[:relations].concat(klasses)
    end

    # Mapper sub-classes are being registered with this method during setup
    #
    # @api private
    def register_mapper(*klasses)
      components[:mappers].concat(klasses)
    end

    # Command sub-classes are being registered with this method during setup
    #
    # @api private
    def register_command(*klasses)
      components[:commands].concat(klasses)
    end

    # @api private
    def relation_classes
      @relation_classes ||= components[:relations].concat(loader&.relations || [])
    end

    # @api private
    def command_classes
      @command_classes ||= components[:commands].concat(loader&.commands || [])
    end

    # @api private
    def mapper_classes
      @mapper_classes ||= components[:mappers].concat(loader&.mappers || [])
    end

    # @api private
    def register_plugin(plugin)
      plugins << plugin
    end

    private

    # @api private
    def loader
      @loader ||= Loader.new(@auto_register[0], **(@auto_register[1] || {})) if @auto_register
    end
  end
end
