# frozen_string_literal: true

require_relative "compat/setup"

require "rom/support/inflector"
require "rom/command"

require "rom/setup"
require "rom/configuration"

require "rom/components/relation"
require "rom/components/command"
require "rom/components/mapper"

module ROM
  class Setup
    attr_accessor :inflector
  end

  module Components
    class Relation < Core
      undef :id

      def id
        return options[:id] if options[:id]

        if constant.respond_to?(:relation_name)
          constant.relation_name
        else
          Inflector.underscore(constant.name)
        end.to_sym
      end
    end

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

  class Configuration
    def_delegators :@setup, :auto_registration

    alias_method :environment, :gateways

    # @api public
    # @deprecated
    def inflector=(inflector)
      setup.inflector = inflector
      config.inflector = inflector
    end

    # @api private
    def relation_classes(gateway = nil)
      classes = setup.components.relations.map(&:constant)

      return classes unless gateway

      gw_name = gateway.is_a?(Symbol) ? gateway : gateways_map[gateway]
      classes.select { |rel| rel.gateway == gw_name }
    end

    # @api private
    # @deprecated
    def gateways_map
      @gateways_map ||= gateways.to_a.map(&:reverse).to_h
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
      gateways.fetch(name) { super }
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
      def create_class(relation:, **, &block)
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
