# frozen_string_literal: true

require "dry/core/equalizer"

require "rom/support/inflector"
require "rom/support/notifications"

require "rom/core"
require "rom/components/provider"

require "rom/open_struct"
require "rom/constants"
require "rom/gateway"
require "rom/loader"

module ROM
  # @api public
  class Runtime
    extend Notifications

    include ROM::Provider(
      :gateway,
      :dataset,
      :schema,
      :relation,
      :association,
      :mapper,
      :command,
      :plugin,
      type: :component
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

    # Global defaults
    setting :inflector, default: Inflector, reader: true

    setting :gateways, default: EMPTY_HASH

    setting :class_name_inferrer, default: DEFAULT_CLASS_NAME_INFERRER, reader: true

    setting :class_namespace, default: DEFAULT_CLASS_NAMESPACE, reader: true

    setting :auto_register do
      setting :root_directory
      setting :auto_load
      setting :namespace
      setting :component_dirs, default: {
        relations: :relations, mappers: :mappers, commands: :commands
      }
      setting :inflector, default: Inflector
    end

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
      super()
      @notifications = Notifications.event_bus(:configuration)
      configure(*args, &block)
    end

    # @return [Resolver] Runtime component resolver
    # @api private
    def resolver
      @resolver ||=
        begin
          options = {config: config, notifications: notifications}
          options[:loader] = loader if config.auto_register.auto_load

          super(**options)
        end
    end

    # This is called internally when you pass a block to ROM.container
    #
    # @api private
    def configure(*args)
      # Load config from the arguments passed to the constructor.
      # This *may* override defaults and it's a feature.
      infer_config(*args) unless args.empty?

      # Load adapters explicitly here to ensure their plugins are present for later use
      load_adapters

      # Allow customizations now
      yield(self) if block_given?

      # Register gateway components based on current config
      register_gateways

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
      config.auto_register.update(root_directory: directory, **options)
      self
    end

    # @api private
    def register_constant(type, constant)
      if config.key?(constant.config.component.type)
        parent_config = config[constant.config.component.type]
        const_config = constant.config.component

        const_config.inherit!(parent_config).join!(parent_config)

        # TODO: make this work with all components
        if const_config.key?(:infer_id_from_class) && const_config.infer_id_from_class
          const_config.id = const_config.inflector.component_id(constant.name)&.to_sym
        end
      end

      components.add(type, constant: constant, config: constant.config.component)
    end

    # Register relation class(es) explicitly
    #
    # @param [Array<Relation>] *klasses One or more relation classes
    #
    # @api public
    def register_relation(*klasses)
      klasses.each do |klass|
        register_constant(:relations, klass)
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
        register_constant(:mappers, klass)
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
        register_constant(:commands, klass)
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
      resolver
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
      ROM.plugins
    end

    # This register gateway components based on the configuration
    #
    # It is private unlike the rest of register_ methods because
    # it's called automatically doing configuration phase
    #
    # @api private
    def register_gateways
      config.gateways.each do |id, gateway_config|
        base = gateway_config.to_h
        keys = base.keys - config.gateway.keys
        args = base[:args] || EMPTY_ARRAY
        opts = keys.zip(base.values_at(*keys)).to_h

        gateway(id, **base, args: args, opts: opts)
      end
    end

    # This infers config using arguments passed to the constructor
    #
    # @api private
    def infer_config(*args)
      config.gateways = ROM::OpenStruct.new

      gateways_config = args.first.is_a?(Hash) ? args.first : {default: args}

      gateways_config.each do |name, value|
        args = Array(value)

        adapter, *rest = args

        options =
          if rest.size > 1 && rest.last.is_a?(Hash)
            {adapter: adapter, args: rest[0..-1], **rest.last}
          else
            options = rest.first.is_a?(Hash) ? rest.first : {args: rest.flatten(1)}
            {adapter: adapter, **options}
          end

        config.gateways[name] = ROM::OpenStruct.new(options)
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
      config.gateways.map { |key| config.gateways[key] }.map(&:adapter).uniq do |adapter|
        Gateway.class_from_symbol(adapter)
      rescue AdapterLoadError
        # TODO: we probably want to remove this. It's perfectly fine to have an adapter
        #       defined in another location. Auto-require was done for convenience but
        #       making it mandatory to have that file seems odd now.
      end
    end

    # @api private
    def plugins
      config.component.plugins
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
