require 'dry/core/class_attributes'

require 'rom/constants'
require 'rom/types'
require 'rom/initializer'
require 'rom/relation/name'
require 'rom/associations/through_identifier'

module ROM
  module Associations
    module Definitions
      # Abstract association definition object
      #
      # @api public
      class Abstract
        include Dry::Equalizer(:source, :target, :result)
        extend Initializer
        extend Dry::Core::ClassAttributes

        defines :result

        # @!attribute [r] source
        #   @return [Relation::Name] the source relation name
        param :source

        # @!attribute [r] target
        #   @return [Relation::Name] the target relation name
        param :target

        # @!attribute [r] relation
        #   @return [Symbol] an optional relation identifier for the target
        option :relation, Types::Strict::Symbol, optional: true

        # @!attribute [r] result
        #   @return [Symbol] either :one or :many
        option :result, Types::Strict::Symbol, default: -> { self.class.result }

        # @!attribute [r] name
        #   @return [Symbol] The name of an association
        option :name, Types::Strict::Symbol, default: -> { target.to_sym }

        # @!attribute [r] alias
        #   @return [Symbol] An optional association alias
        option :as, Types::Strict::Symbol.optional, optional: true

        # @!attribute [r] foreign_key
        #   @return [Symbol] an optional association alias name
        option :foreign_key, Types::Optional::Strict::Symbol, optional: true

        # @!attribute [r] view
        #   @return [Symbol] An optional view that should be used to extend assoc relation
        option :view, optional: true

        # @!attribute [r] override
        #   @return [TrueClass,FalseClass] Whether custom view should override default one or not
        option :override, optional: true, default: -> { false }

        # @!attribute [r] combine_keys
        #   @return [Hash<Symbol=>Symbol>] Override inferred combine keys
        option :combine_keys, optional: true

        # Instantiate a new association definition
        #
        # @param [Symbol] source The name of the source dataset
        # @param [Symbol] target The name of the target dataset
        # @param [Hash] opts The option hash
        # @option opts [Symbol] :as The name of the association (defaults to target)
        # @option opts [Symbol] :relation The name of the target relation (defaults to target)
        # @option opts [Symbol] :foreign_key The name of a custom foreign key
        # @option opts [Symbol] :view The name of a custom relation view on the target's relation side
        # @option opts [TrueClass,FalseClass] :override Whether provided :view should override association's default view
        #
        # @api public
        def self.new(source, target, opts = EMPTY_HASH)
          source_name = Relation::Name[source]
          target_name = resolve_target_name(target, opts)
          options = process_options(target_name, Hash[opts])

          super(source_name, target_name, options)
        end

        # @api private
        def self.resolve_target_name(target, options)
          dataset = target
          relation = options.fetch(:relation, target)

          Relation::Name[relation, dataset, options[:as]]
        end

        # @api private
        def self.process_options(target, options)
          through = options[:through]

          if through
            options[:through] = ThroughIdentifier[through, target.relation, options[:assoc]]
          end

          options[:name] = target.relation

          options
        end

        # Return true if association's default relation view should be overridden by a custom one
        #
        # @return [Boolean]
        #
        # @api public
        def override?
          options[:override].equal?(true)
        end

        # Return true if association is aliased
        #
        # @return [Boolean]
        #
        # @api public
        def aliased?
          options.key?(:as)
        end

        # Return association class for a given definition object
        #
        # @return [Class]
        #
        # @api public
        def type
          ROM.inflector.demodulize(self.class.name).to_sym
        end
      end
    end
  end
end
