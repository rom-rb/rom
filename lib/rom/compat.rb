# frozen_string_literal: true

require "dry/core/class_attributes"

require "rom/support/inflector"

require "rom/configuration"
require "rom/compat/auto_registration"

require "rom/components"

module ROM
  module Components
    undef :infer_option

    # @api private
    def infer_option(option, component:)
      if component.provider && component.provider != self
        component.provider.infer_option(option, component: component)
      elsif component.option?(:constant) && component.constant.respond_to?(:infer_option)
        component.constant.infer_option(option, component: component)
      elsif component.option?(:constant)
        Inflector.component_id(component.constant).to_sym
      end
    end
  end

  # @api public
  class Configuration
    # @api public
    # @deprecated
    def inflector=(inflector)
      config.inflector = inflector
    end

    # Enable auto-registration for a given configuration object
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
    # @see Configuration#auto_register
    #
    # @api public
    def auto_registration(directory, **options)
      auto_registration = AutoRegistration.new(directory, inflector: inflector, **options)
      auto_registration.relations.each { |r| register_relation(r) }
      auto_registration.commands.each { |r| register_command(r) }
      auto_registration.mappers.each { |r| register_mapper(r) }
      self
    end

    # @api private
    # @deprecated
    def relation_classes(gateway = nil)
      classes = components.relations.map(&:constant)

      return classes unless gateway

      gw_name = gateway.is_a?(Symbol) ? gateway : gateways_map[gateway]
      classes.select { |rel| rel.gateway == gw_name }
    end

    # @api public
    # @deprecated
    def command_classes
      components.commands.map(&:constant)
    end

    # @api public
    # @deprecated
    def mapper_classes
      components.mappers.map(&:constant)
    end

    # @api public
    # @deprecated
    def [](key)
      gateways.fetch(key)
    end

    # @api public
    # @deprecated
    def gateways
      @gateways ||= components.gateways.map(&:build).map { |gw| [gw.config.name, gw] }.to_h
    end
    alias_method :environment, :gateways

    # @api private
    # @deprecated
    def gateways_map
      @gateways_map ||= gateways.map(&:reverse).to_h
    end

    # @api private
    def respond_to_missing?(name, include_all = false)
      gateways.key?(name) || super
    end

    private

    # Returns gateway if method is a name of a registered gateway
    #
    # @return [Gateway]
    #
    # @api public
    # @deprecated
    def method_missing(name, *)
      gateways[name] || super
    end
  end

  module SettingProxy
    extend Dry::Core::ClassAttributes

    # Delegate to config when accessing deprecated class attributes
    #
    # @api private
    def method_missing(name, *args, &block)
      return super unless setting_mapping.key?(name)

      mapping = setting_mapping[name]
      ns, key = mapping

      if args.empty?
        if mapping.empty?
          config[name]
        else
          config[ns][key]
        end
      else
        value = args.first

        if mapping.empty?
          config[name] = value
        else
          config[ns][key] = value
        end
      end
    end
  end

  require "rom/transformer"

  Transformer.class_eval do
    class << self
      prepend SettingProxy

      # Configure relation for the transformer
      #
      # @example with a custom name
      #   class UsersMapper < ROM::Transformer
      #     relation :users, as: :json_serializer
      #
      #     map do
      #       rename_keys user_id: :id
      #       deep_stringify_keys
      #     end
      #   end
      #
      #   users.map_with(:json_serializer)
      #
      # @param name [Symbol]
      # @param options [Hash]
      # @option options :as [Symbol] Mapper identifier
      #
      # @deprecated
      #
      # @api public
      def relation(name = Undefined, as: name)
        if name == Undefined
          config.component.relation_id
        else
          config.component.relation_id = name
          config.component.id = as
        end
      end

      def setting_mapping
        @setting_mapping ||= {
          register_as: [:component, :id],
          relation: [:component, :relation_id]
        }.freeze
      end

      # @api private
      def infer_option(option, component:)
        case option
        when :id
          component.constant.register_as ||
            component.constant.relation ||
            Inflector.component_id(component.constant.name).to_sym
        when :relation_id
          component.constant.relation || component.constant.base_relation
        end
      end
    end
  end

  require "rom/mapper"

  class Mapper
    class << self
      prepend SettingProxy

      def setting_mapping
        @setting_mapper ||= {
          register_as: [:component, :id],
          relation: [:component, :relation_id],
          inherit_header: [],
          reject_keys: [],
          symbolize_keys: [],
          copy_keys: [],
          prefix: [],
          prefix_separator: []
        }.freeze
      end

      # @api private
      def infer_option(option, component:)
        case option
        when :id
          component.constant.register_as ||
            component.constant.relation ||
            Inflector.component_id(component.constant.name).to_sym
        when :relation_id
          component.constant.relation || component.constant.base_relation
        end
      end
    end
  end

  require "rom/command"

  class Command
    extend Dry::Core::ClassAttributes

    module Restrictable
      extend ROM::Notifications::Listener

      subscribe("configuration.commands.class.before_build") do |event|
        command = event[:command]
        relation = event[:relation]
        command.extend_for_relation(relation) if command.restrictable
      end

      # @api private
      def create_class(relation: nil, **, &block)
        klass = super
        klass.extend_for_relation(relation) if relation && klass.restrictable
        klass
      end
    end

    class << self
      prepend Restrictable
      prepend SettingProxy

      def setting_mapping
        @setting_mapper ||= {
          adapter: [:component, :adapter],
          relation: [:component, :relation_id],
          register_as: [:component, :id],
          restrictable: [],
          result: [],
          input: []
        }.freeze
      end
    end

    # Extend a command class with relation view methods
    #
    # @param [Relation] relation
    #
    # @return [Class]
    #
    # @api public
    # @deprecated
    def self.extend_for_relation(relation)
      include(relation_methods_mod(relation.class))
    end

    # @api private
    def self.relation_methods_mod(relation_class)
      Module.new do
        relation_class.view_methods.each do |meth|
          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{meth}(*args)
              response = relation.public_send(:#{meth}, *args)

              if response.is_a?(relation.class)
                new(response)
              else
                response
              end
            end
          RUBY
        end
      end
    end
  end

  require "rom/relation"

  class Relation
    class << self
      prepend SettingProxy

      def setting_mapping
        @setting_mapping ||= {
          auto_map: [],
          auto_struct: [],
          struct_namespace: [],
          wrap_class: [],
          adapter: [:component, :adapter],
          gateway: [:component, :gateway],
          schema_class: [:schema, :constant],
          schema_dsl: [:schema, :dsl_class],
          schema_attr_class: [:schema, :attr_class],
          schema_inferrer: [:schema, :inferrer]
        }.freeze
      end
    end

    # This is used by the deprecated command => relation view delegation syntax
    # @api private
    def self.view_methods
      ancestor_methods = ancestors.reject { |klass| klass == self }
        .map(&:instance_methods).flatten(1)

      instance_methods - ancestor_methods + auto_curried_methods.to_a
    end
  end
end
