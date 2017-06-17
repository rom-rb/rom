require 'dry/core/constants'
require 'dry/core/class_attributes'

require 'rom/types'
require 'rom/initializer'
require 'rom/associations/name'

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
        #   @return [ROM::Relation::Name] the source relation name
        param :source

        # @!attribute [r] target
        #   @return [ROM::Relation::Name] the target relation name
        param :target

        # @!attribute [r] relation
        #   @return [Symbol] an optional relation identifier for the target
        option :relation, Types::Strict::Symbol, optional: true

        # @!attribute [r] result
        #   @return [Symbol] either :one or :many
        option :result, Types::Strict::Symbol, default: -> { self.class.result }

        # @!attribute [r] as
        #   @return [Symbol] an optional association alias name
        option :as, Types::Strict::Symbol, default: -> { target.to_sym }

        # @!attribute [r] foreign_key
        #   @return [Symbol] an optional association alias name
        option :foreign_key, Types::Optional::Strict::Symbol, optional: true

        # @!attribute [r] view
        #   @return [Symbol] An optional view that should be used to extend assoc relation
        option :view, optional: true

        # @!attribute [r] override
        #   @return [TrueClass,FalseClass] Whether custom view should override default one or not
        option :override, optional: true, default: -> { false }

        alias_method :name, :as

        # @api public
        def self.new(source, target, options = EMPTY_HASH)
          super(
            Name[source],
            Name[options[:relation] || target, target, options[:as] || target],
            options
          )
        end

        # @api public
        def override?
          options[:override].equal?(true)
        end

        # @api public
        def type
          Dry::Core::Inflector.demodulize(self.class.name).to_sym
        end
      end
    end
  end
end
