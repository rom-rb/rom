require 'set'

module ROM
  module Plugins
    module Command
      # A plugin for transparently translating schema defined aliases
      # into canonical names expected by adapters.
      #
      # @example
      #   class User < ROM::Relations[:sql]
      #     schema(infer: true) do
      #       attribute :first_name, alias: name
      #     end
      #   end
      #
      #   class CreateUser < ROM::Commands::Create[:sql]
      #     result :one
      #     use :alias
      #   end
      #
      #   result = rom.command(:user).create.call(name: 'Jane')
      #   result[:first_name]  #=> 'Jane'
      #
      # @api public
      module Alias
        module T
          extend Transproc::Registry

          import :rename_keys, from: Transproc::HashTransformations
        end

        # @api private
        def self.included(klass)
          super
          klass.before :map_aliases
          klass.include(InstanceMethods)
        end

        module InstanceMethods
          # @api private
          def map_aliases(tuples, *)
            mapping = relation.class.schema.alias_mapping.invert
            map_input_tuples(tuples) do |t|
              T[:rename_keys].(t, mapping)
            end
          end
        end
      end
    end
  end
end
