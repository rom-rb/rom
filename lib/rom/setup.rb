# frozen_string_literal: true

require "rom/support/configurable"
require "rom/loader"
require "rom/components"
require "rom/gateway"
require "rom/gateway_registry"
require "rom/relation_registry"

module ROM
  # Setup objects collect component classes during setup/finalization process
  #
  # @api private
  class Setup
    # @api private
    attr_reader :plugins

    # @api private
    attr_accessor :inflector

    # @api private
    attr_reader :components

    # @api private
    attr_reader :gateways

    # @api private
    attr_reader :relations

    # @api private
    attr_reader :config

    # @api private
    attr_reader :cache

    # @api private
    def initialize(
      components: Components::Registry.new,
      auto_register: EMPTY_HASH,
      cache: Cache.new,
      config: Configurable::Config.new
    )
      @plugins = []
      @cache = cache
      @config = config
      @inflector = Inflector
      @components = components
      @gateways = GatewayRegistry.new(
        {}, cache: cache, config: config, resolver: method(:load_gateway)
      )
      @relations = RelationRegistry.build
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
    def load_gateways
      config.each_key do |name|
        load_gateway(name) unless gateways.key?(name)
      end
    end

    # @api private
    def load_gateway(name)
      gateway_config = config[name]

      return unless gateway_config.key?(:adapter)

      gateway =
        if gateway_config.adapter.is_a?(Gateway)
          gateway_config.adapter
        else
          Gateway.setup(gateway_config.adapter, gateway_config)
        end

      # TODO: this is here to keep backward compatibility
      gateway_config.name = name
      gateway.instance_variable_set(:"@config", gateway_config)

      gateways.add(name, gateway)
    end

    private

    # @api private
    def loader
      @loader ||= Loader.new(@auto_register.fetch(:root_directory), **@auto_register)
    end
  end
end
