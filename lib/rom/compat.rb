# frozen_string_literal: true

require_relative "compat/setup"
require "rom/command"

module ROM
  class Configuration
    def_delegators :@setup, :auto_registration
    def_delegators :@gateways, :gateways_map

    alias_method :environment, :gateways

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
      def create_class(name, relation: nil, **opts, &block)
        klass = super
        klass.extend_for_relation(relation) if relation && klass.restrictable
        klass
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

    Command::ClassInterface.prepend(Restrictable)
  end
end
