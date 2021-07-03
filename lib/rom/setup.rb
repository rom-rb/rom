# frozen_string_literal: true

require "dry/core/memoizable"

require "rom/support/configurable"
require "rom/loader"
require "rom/components"
require "rom/gateway"

module ROM
  # Setup objects collect component classes during setup/finalization process
  #
  # @api private
  class Setup
    include Dry::Core::Memoizable

    # @api private
    attr_reader :plugins

    # @api private
    attr_reader :components

    # @api private
    attr_reader :gateways

    # @api private
    attr_reader :config

    # @api private
    attr_reader :cache

    # @api private
    def initialize(components:, config:, auto_register: EMPTY_HASH, cache: Cache.new)
      @plugins = []
      @cache = cache
      @config = config
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
    def register_relation(*klasses, **opts)
      klasses.each do |klass|
        components.add(:relations, constant: klass, **opts)
      end

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

    # @api private
    def load_adapters
      config.each { |_, gateway_config| gateway_config.adapter }.uniq.each do |adapter|
        begin
          Gateway.class_from_symbol(adapter)
        rescue AdapterLoadError
          # TODO: we probably want to remove this. It's perfectly fine to have an adapter
          #       defined in another location. Auto-require was done for convenience but
          #       making it mandatory to have that file seems odd now.
        end
      end
    end

    # @api private
    def register_gateways
      config.each do |id, gateway_config|
        components.add(:gateways, id: id, config: gateway_config)
      end
    end

    private

    # @api private
    def loader
      @loader ||= Loader.new(@auto_register.fetch(:root_directory), **@auto_register)
    end
  end
end
