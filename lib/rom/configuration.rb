# frozen_string_literal: true

require "dry/core/equalizer"

require "rom/support/inflector"
require "rom/support/notifications"
require "rom/support/configurable"

require "rom/constants"
require "rom/gateway"
require "rom/loader"
require "rom/components"

module ROM
  # @api public
  class Configuration
    extend Notifications

    include Dry::Equalizer(:config)
    include Configurable

    include ROM.Components(
      :dataset,
      :schema,
      :relation,
      :mappers,
      :commands,
      :plugin
    )

    DEFAULT_CLASS_NAMESPACE = "ROM"

    CLASS_NAME_INFERRERS = {
      relation: -> (name, type:, inflector:, class_namespace:, **) {
        [class_namespace,
         inflector.pluralize(inflector.camelize(type)),
         inflector.camelize(name)
        ].compact.join("::")
      },
      command: -> (name, inflector:, adapter:, command_type:, class_namespace:, **) {
          [class_namespace,
           inflector.classify(adapter),
           "Commands",
           "#{command_type}[#{inflector.pluralize(inflector.classify(name))}]"
          ].join("::")
      }
    }

    DEFAULT_CLASS_NAME_INFERRER = -> (name, type:, **opts) {
      CLASS_NAME_INFERRERS.fetch(type).(name, type: type, **opts)
    }.freeze

    register_event("configuration.relations.class.ready")
    register_event("configuration.relations.object.registered")
    register_event("configuration.relations.registry.created")
    register_event("configuration.relations.schema.allocated")
    register_event("configuration.relations.schema.set")
    register_event("configuration.relations.dataset.allocated")
    register_event("configuration.commands.class.before_build")

    # @return [Notifications] Notification bus instance
    # @api private
    attr_reader :notifications

    # Initialize a new configuration
    #
    # @return [Configuration]
    #
    # @api private
    def initialize(*args, &block)
      @notifications = Notifications.event_bus(:configuration)
      configure(*args, &block)
    end

    # @api private
    def inflector
      config.inflector
    end

    # @api private
    def class_name_inferrer
      config.components.class_name_inferrer
    end

    # This is called internally when you pass a block to ROM.container
    #
    # @api private
    def configure(*args)
      # Global defaults
      config.inflector = Inflector
      config.auto_register.root_directory = nil
      config.gateways = Config.new

      # Component defaults
      config.components.class_name_inferrer = DEFAULT_CLASS_NAME_INFERRER
      config.components.class_namespace = DEFAULT_CLASS_NAMESPACE

      Components::CORE_TYPES.each do |type|
        config.components[inflector.singularize(type)].namespace = inflector.component_id(type)
      end

      # Load config from the arguments passed to the constructor.
      # This *may* override defaults and it's a feature.
      infer_config(*args) unless args.empty?

      # Load adapters explicitly here to ensure their plugins are present for later use
      load_adapters

      # Register gateway components in case some custom configuration needs them
      register_gateways

      # TODO: this is tricky because if you want to tweak the config in the block
      #       you end up doing `config.config.foo = "bar"` so it would be good
      #       to yield configuration object + its config or rename this whole class
      #       because it's a configuration *DSL* that builds up a config object too
      yield(self) if block_given?

      self
    end

    # Enable auto-registration
    #
    # @param [String, Pathname] directory The root path to components
    # @param [Hash] options
    # @option options [Boolean,String] :namespace Toggle root namespace
    #
    # @return [Configuration]
    #
    # @api public
    def auto_register(directory, **options)
      load_config(config.auto_register, options.merge(root_directory: directory))
      self
    end

    # Register relation class(es) explicitly
    #
    # @param [Array<Relation>] *klasses One or more relation classes
    #
    # @api public
    def register_relation(*klasses)
      klasses.each do |klass|
        components.add(:relations, constant: klass, provider: klass)
      end

      components.relations
    end

    # Register mapper class(es) explicitly
    #
    # @param [Array] *klasses One or more mapper classes
    #
    # @api public
    def register_mapper(*klasses)
      klasses.each do |klass|
        components.add(:mappers, constant: klass, provider: klass)
      end

      components[:mappers]
    end

    # Register command class(es) explicitly
    #
    # @param [Array] *klasses One or more command classes
    #
    # @api public
    def register_command(*klasses)
      klasses.each do |klass|
        components.add(:commands, constant: klass, provider: klass)
      end

      components.commands
    end

    # This is called automatically in configure block
    #
    # After finalization it is no longer possible to alter the configuration
    #
    # @api private
    def finalize
      # No more config changes allowed
      config.freeze
      attach_listeners
      loader.() if config.auto_register.key?(:root_directory)
      self
    end

    # Apply a plugin to the configuration
    #
    # @param [Mixed] plugin The plugin identifier, usually a Symbol
    # @param [Hash] options Plugin options
    #
    # @return [Configuration]
    #
    # @api public
    def use(plugin, options = {})
      case plugin
      when Array then plugin.each { |p| use(p) }
      when Hash then plugin.to_a.each { |p| use(*p) }
      else
        plugin_registry[:configuration].fetch(plugin).apply_to(self, options)
      end

      self
    end

    private

    # @api private
    def plugin_registry
      ROM.plugin_registry
    end

    # This register gateway components based on the configuration
    #
    # It is private unlike the rest of register_ methods because
    # it's called automatically doing configuration phase
    #
    # @api private
    def register_gateways
      config.gateways.each do |id, gateway_config|
        components.add(
          :gateways,
          id: id, namespace: "gateways", provider: self, config: gateway_config
        )
      end
    end

    # This infers config using arguments passed to the constructor
    #
    # @api private
    def infer_config(*args)
      gateways_config = args.first.is_a?(Hash) ? args.first : {default: args}

      gateways_config.each do |name, value|
        args = Array(value)

        adapter, *rest = args

        if rest.size > 1 && rest.last.is_a?(Hash)
          load_config(config.gateways[name], {adapter: adapter, args: rest[0..-1], **rest.last})
        else
          options = rest.first.is_a?(Hash) ? rest.first : {args: rest.flatten(1)}
          load_config(config.gateways[name], {adapter: adapter, **options})
        end
      end
    end

    # @api private
    def load_config(config, hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          load_config(config[key], value)
        else
          config.send("#{key}=", value)
        end
      end
    end

    # @api private
    def attach_listeners
      # Anything can attach globally to certain events, including plugins, so here
      # we're making sure that only plugins that are enabled in this configuration
      # will be triggered
      global_listeners = Notifications.listeners.to_a
        .reject { |(src, *)| plugin_registry.map(&:mod).include?(src) }.to_h

      plugin_listeners = Notifications.listeners.to_a
        .select { |(src, *)| plugins.map(&:mod).include?(src) }.to_h

      listeners.update(global_listeners).update(plugin_listeners)
    end

    # @api private
    def listeners
      notifications.listeners
    end

    # @api private
    def load_adapters
      config.gateways.each { |_, gateway_config| gateway_config.adapter }.uniq.each do |adapter|
        Gateway.class_from_symbol(adapter)
      rescue AdapterLoadError
        # TODO: we probably want to remove this. It's perfectly fine to have an adapter
        #       defined in another location. Auto-require was done for convenience but
        #       making it mandatory to have that file seems odd now.
      end
    end

    # @api private
    def loader
      @loader ||= Loader.new(
        config.auto_register.root_directory,
        components: components,
        **config.auto_register
      )
    end
  end
end
