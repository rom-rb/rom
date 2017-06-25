require 'dry/core/constants'
require 'dry/core/class_attributes'

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
        include Dry::Core::Constants
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

        # Instantiate a new association definition
        #
        # @param [Symbol] source The name of the source dataset
        # @param [Symbol] target The name of the target dataset
        # @param [Hash] options The option hash
        # @option options [Symbol] :as The name of the association (defaults to target)
        # @option options [Symbol] :relation The name of the target relation (defaults to target)
        # @option options [Symbol] :foreign_key The name of a custom foreign key
        # @option options [Symbol] :view The name of a custom relation view on the target's relation side
        # @option options [TrueClass,FalseClass] :override Whether provided :view should override association's default view
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

        # @api public
        def override?
          options[:override].equal?(true)
        end

        # @api public
        def aliased?
          options.key?(:as)
        end

        # @api public
        def type
          Dry::Core::Inflector.demodulize(self.class.name).to_sym
        end
      end
    end
  end
end
