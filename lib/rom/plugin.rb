# frozen_string_literal: true

require "rom/initializer"
require "rom/open_struct"

module ROM
  # Plugin is a simple object used to store plugin configurations
  #
  # @private
  class Plugin
    include Dry::Equalizer(:type, :name, :mod, :adapter, :config, :dsl)
    extend Initializer

    # @!attribute [r] type
    #   @return [Symbol] plugin type
    # @api private
    option :type

    # @!attribute [r] name
    #   @return [Symbol] plugin name
    # @api private
    option :name

    # @!attribute [r] mod
    #   @return [Module] a module representing the plugin
    # @api private
    option :mod

    # @!attribute [r] adapter
    #   @return [Symbol] plugin adapter
    # @api private
    option :adapter, optional: true

    # @!attribute [r] config
    #   @return [Symbol] Plugin optional config
    option :config, default: -> { ROM::OpenStruct.new }

    # @!attribute [r] dsl
    #   @return [Module,nil] Optional DSL extensions
    option :dsl, default: -> { mod.const_defined?(:DSL) ? mod.const_get(:DSL) : nil }

    # These opts are excluded when passing to mod's `apply`
    INTERNAL_OPTS = %i[enabled applied target].freeze

    # Plugin registry key
    #
    # @return [String]
    #
    # @api private
    def key
      [adapter, type, name].compact.join(".")
    end

    # Configure plugin
    #
    # @api public
    def configure(**options)
      plugin = dup
      plugin.config.update(options)
      yield(plugin.config) if block_given?
      plugin
    end

    # @api private
    def dup
      with(config: ROM::OpenStruct.new(config.to_h.clone))
    end

    # @api private
    def enable(target)
      target.extend(dsl) if dsl
      config.enabled = true
      config.target = target
      self
    end

    # @api private
    def apply
      if enabled?
        apply_to(config.target, **plugin_options)
        config.applied = true
        config.freeze
        freeze
        self
      else
        raise "Cannot apply a plugin because it was not enabled for any target"
      end
    end

    # @api private
    def enabled?
      config.key?(:enabled) && config.enabled == true
    end

    # @api private
    def applied?
      config.key?(:applied) && config.applied == true
    end

    # @api private
    def plugin_options
      (opts = config.to_h).slice(*(opts.keys - INTERNAL_OPTS))
    end

    private

    # Apply this plugin to the target
    #
    # @param [Class,Object] target
    #
    # @api private
    def apply_to(target, **options)
      if mod.respond_to?(:apply)
        mod.apply(target, **config, **options)
      elsif mod.respond_to?(:new)
        target.include(mod.new(**options))
      elsif mod.is_a?(::Module)
        # Target can be either a component class, like a Relation class, or a DSL object
        # If it's the former, just include the module, if it's the latter, assume it defines
        # a component constant and include it there
        if target.is_a?(Class)
          target.include(mod)
        elsif target.respond_to?(:constant)
          target.constant.include(mod)
        end
      end
      self
    end
  end
end
