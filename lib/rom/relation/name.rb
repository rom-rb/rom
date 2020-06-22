# frozen_string_literal: true

require 'dry/equalizer'
require 'concurrent/map'

module ROM
  class Relation
    # Relation name container
    #
    # This is a simple struct with two fields.
    # It handles both relation registration name (i.e. Symbol) and dataset name.
    # The reason we need it is a simplification of passing around these two objects.
    # It is quite common to have a dataset named differently from a relation
    # built on top if you are dealing with a legacy DB and often you need both
    # to support things such as associations (rom-sql as an example).
    #
    # @api private
    class Name
      include Dry::Equalizer(:relation, :dataset, :key)

      # Coerce an object to a Name instance
      #
      # @return [ROM::Relation::Name]
      #
      # @api private
      def self.[](*args)
        cache.fetch_or_store(args.hash) do
          relation, dataset, aliaz = args

          if relation.is_a?(Name)
            relation
          else
            new(relation, dataset, aliaz)
          end
        end
      end

      # @api private
      def self.cache
        @cache ||= Concurrent::Map.new
      end

      # Relation registration name
      #
      # @return [Symbol]
      #
      # @api private
      attr_reader :relation

      # Underlying dataset name
      #
      # @return [Symbol]
      #
      # @api private
      attr_reader :dataset

      attr_reader :aliaz

      attr_reader :key

      # @api private
      def initialize(relation, dataset = relation, aliaz = nil)
        @relation = relation
        @dataset = dataset || relation
        @key = aliaz || relation
        @aliaz = aliaz
      end

      # @api private
      def as(aliaz)
        self.class[relation, dataset, aliaz]
      end

      # @api private
      def aliased?
        aliaz && aliaz != relation
      end

      # Return relation name
      #
      # @return [String]
      #
      # @api private
      def to_s
        if aliased?
          "#{relation} on #{dataset} as #{aliaz}"
        elsif relation == dataset
          relation.to_s
        else
          "#{relation} on #{dataset}"
        end
      end

      # Alias for registration key implicitly called by ROM::Registry
      #
      # @return [Symbol]
      #
      # @api private
      def to_sym
        relation
      end

      # Return inspected relation
      #
      # @return [String]
      #
      # @api private
      def inspect
        "#{self.class.name}(#{self})"
      end
    end
  end
end
