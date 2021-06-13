# frozen_string_literal: true

require "rom/loader"
require "rom/components"

module ROM
  # Setup objects collect component classes during setup/finalization process
  #
  # @api public
  class Setup
    # @api private
    attr_reader :plugins

    # @api private
    attr_accessor :inflector

    # @api private
    attr_reader :components

    # @api private
    def initialize(components: Components::Registry.new, auto_register: EMPTY_HASH)
      @plugins = []
      @inflector = Inflector
      @components = components
      @auto_register = auto_register.merge(root_directory: nil, components: components)
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
    def auto_register(directory, options = {})
      @auto_register.update(options).update(root_directory: directory)
      self
    end

    # Relation sub-classes are being registered with this method during setup
    #
    # @api private
    def register_relation(*klasses)
      klasses.each { |klass| components.add(:relations, constant: klass) }
      components.relations
    end

    # Mapper sub-classes are being registered with this method during setup
    #
    # @api private
    def register_mapper(*klasses)
      klasses.each do |klass|
        components.add(:mappers, constant: klass)
      end
      components[:mappers]
    end

    # Command sub-classes are being registered with this method during setup
    #
    # @api private
    def register_command(*klasses)
      klasses.each do |klass|
        components.add(:commands, constant: klass)
      end

      components.commands
    end

    # @api private
    def finalize
      loader.()
      freeze
      self
    end

    # @api private
    def register_plugin(plugin)
      plugins << plugin
    end

    private

    # @api private
    def loader
      @loader ||= Loader.new(@auto_register.fetch(:root_directory), **@auto_register)
    end
  end
end
