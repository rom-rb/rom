# frozen_string_literal: true

require "rom/support/inflector"

require "rom/relation"
require "rom/command"

require "rom/configuration"
require "rom/compat/auto_registration"

require "rom/components/relation"
require "rom/components/command"
require "rom/components/mapper"

module ROM
  module Components
    class Command < Core
      undef :id
      undef :relation_id

      def id
        return options[:id] if options[:id]

        if constant.respond_to?(:register_as)
          constant.register_as || constant.default_name
        else
          Inflector.underscore(constant.name)
        end
      end

      def relation_id
        constant.relation if constant.respond_to?(:relation)
      end
    end

    class Mapper < Core
      undef :id
      undef :relation_id

      def id
        return options[:id] if options[:id]

        if constant.respond_to?(:id)
          constant.id
        else
          Inflector.underscore(constant.name)
        end
      end

      def relation_id
        return options[:base_relation] if options[:base_relation]

        constant.base_relation if constant.respond_to?(:base_relation)
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

  class Relation
    # This is needed to be able to infer default setting values from
    # deprecated class-level attrs
    SETTING_DEFAULT_PROC = -> (name, value, klass) {
      klass.respond_to?(name) ? klass.__send__(name) : value
    }

    SETTING_DEFAULTS = {
      "schema.constant"   => [:schema_class, Schema],
      "schema.dsl_class"  => [:schema_dsl, Schema::DSL],
      "schema.attr_class" => [:schema_attr_class, Attribute],
      "schema.inferrer"   => [:schema_inferrer, Schema::DEFAULT_INFERRER]
    }

    # This way of configuring components is deprecated but the fallback
    # mechanism makes it possible to start using the new settings API
    # while using class attrs at the same time.
    SETTING_DEFAULTS.each do |_, (class_attr, default)|
      defines(class_attr)
      public_send(class_attr, default)
    end

    # @api private
    def self.define_settings(mappings)
      SETTING_DEFAULTS.group_by { |k, (*)| k.split(".").first.to_sym }.each do |root, mapping|
        setting(root) do
          mapping.each do |(path, (class_attr, value))|
            key = path.split(".").last.to_sym

            setting(key, default: SETTING_DEFAULT_PROC.curry.(class_attr, value))
          end
        end
      end
    end

    define_settings(SETTING_DEFAULTS)

    # This is used by the deprecated command => relation view delegation syntax
    # @api private
    def self.view_methods
      ancestor_methods = ancestors.reject { |klass| klass == self }
        .map(&:instance_methods).flatten(1)

      instance_methods - ancestor_methods + auto_curried_methods.to_a
    end
  end

  class Command
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
      prepend(Restrictable)
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
end
