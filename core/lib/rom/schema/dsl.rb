require 'dry/equalizer'

require 'rom/types'
require 'rom/schema/attribute'
require 'rom/schema/associations_dsl'

module ROM
  # Relation schema
  #
  # @api public
  class Schema
    # @api public
    class DSL < BasicObject
      attr_reader :relation, :attributes, :inferrer, :schema_class, :attr_class, :associations_dsl

      # @api private
      def initialize(relation, schema_class: Schema, attr_class: Attribute, inferrer: Schema::DEFAULT_INFERRER, &block)
        @relation = relation
        @inferrer = inferrer
        @schema_class = schema_class
        @attr_class = attr_class
        @attributes = {}

        if block
          instance_exec(&block)
        end
      end

      # Defines a relation attribute with its type
      #
      # @see Relation.schema
      #
      # @api public
      def attribute(name, type, options = EMPTY_HASH)
        if @attributes.key?(name)
          ::Kernel.raise ::ROM::Schema::AttributeAlreadyDefinedError,
                         "Attribute #{ name.inspect } already defined"
        end

        @attributes[name] =
          if options[:read]
            type.meta(name: name, source: relation, read: options[:read])
          else
            type.meta(name: name, source: relation)
          end
      end

      # Define associations for a relation
      #
      # @example
      #   class Users < ROM::Relation[:sql]
      #     schema(infer: true) do
      #       associations do
      #         has_many :tasks
      #         has_many :posts
      #         has_many :posts, as: :priority_posts, view: :prioritized
      #         belongs_to :account
      #       end
      #     end
      #   end
      #
      #   class Posts < ROM::Relation[:sql]
      #     schema(infer: true) do
      #       associations do
      #         belongs_to :users, as: :author
      #       end
      #     end
      #
      #     view(:prioritized) do
      #       where { priority <= 3 }
      #     end
      #   end
      #
      # @return [AssociationDSL]
      #
      # @api public
      def associations(&block)
        @associations_dsl = AssociationsDSL.new(relation, &block)
      end

      # Specify which key(s) should be the primary key
      #
      # @api public
      def primary_key(*names)
        names.each do |name|
          attributes[name] = attributes[name].meta(primary_key: true)
        end
        self
      end

      # @api private
      def call
        schema_class.define(relation, opts)
      end

      private

      # Return schema opts
      #
      # @return [Hash]
      #
      # @api private
      def opts
        opts = { attributes: attributes.values, inferrer: inferrer, attr_class: attr_class }

        if associations_dsl
          { **opts, associations: associations_dsl.call }
        else
          opts
        end
      end
    end
  end
end
