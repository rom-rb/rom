require 'dry/core/deprecations'
require 'dry/core/class_attributes'

require 'rom/types'
require 'rom/initializer'
require 'rom/pipeline'

require 'rom/commands/class_interface'
require 'rom/commands/composite'
require 'rom/commands/graph'
require 'rom/commands/lazy'

module ROM
  # Abstract command class
  #
  # Provides a constructor accepting relation with options and basic behavior
  # for calling, currying and composing commands.
  #
  # Typically command subclasses should inherit from specialized
  # Create/Update/Delete, not this one.
  #
  # @abstract
  #
  # @private
  class Command
    extend Initializer
    include Dry::Equalizer(:relation, :options)
    include Commands
    include Pipeline::Operator

    extend Dry::Core::ClassAttributes
    extend ClassInterface

    defines :adapter, :relation, :result, :input, :register_as, :restrictable, :before, :after

    # @attr_reader [Relation] relation The command's relation
    param :relation

    CommandType = Types::Strict::Symbol.enum(:create, :update, :delete)
    Result = Types::Strict::Symbol.enum(:one, :many)

    option :type, type: CommandType, optional: true
    option :source, reader: true, optional: true, default: -> c { c.relation }
    option :result, reader: true, type: Result
    option :input, reader: true
    option :curry_args, reader: true, default: -> _ { EMPTY_ARRAY }
    option :before, Types::Coercible::Array, reader: true, as: :before_hooks, default: proc { EMPTY_ARRAY }
    option :after, Types::Coercible::Array, reader: true, as: :after_hooks, default: proc { EMPTY_ARRAY }

    input Hash
    result :many

    # Return name of this command's relation
    #
    # @return [ROM::Relation::Name]
    #
    # @api public
    def name
      relation.name
    end

    # Return gateway of this command's relation
    #
    # @return [Symbol]
    #
    # @api public
    def gateway
      relation.gateway
    end

    # Execute the command
    #
    # @abstract
    #
    # @return [Array] an array with inserted tuples
    #
    # @api private
    def execute(*)
      raise(
        NotImplementedError,
        "#{self.class}##{__method__} must be implemented"
      )
    end

    # Call the command and return one or many tuples
    #
    # @api public
    def call(*args, &block)
      prepared =
        if curried?
          before_hooks.reduce(*curry_args) { |a, e| __send__(e, a, *args) }
        else
          before_hooks.reduce(*args) { |a, e| __send__(e, a) }
        end

      result = prepared ? execute(prepared, &block) : execute(&block)
      finalized = after_hooks.reduce(result) { |a, e| __send__(e, a) }

      if one?
        finalized.first
      else
        finalized
      end
    end
    alias_method :[], :call

    # Curry this command with provided args
    #
    # Curried command can be called without args
    #
    # @return [Command]
    #
    # @api public
    def curry(*args)
      if curry_args.empty? && args.first.is_a?(Graph::InputEvaluator)
        Lazy[self].new(self, *args)
      else
        self.class.build(relation, options.merge(curry_args: args))
      end
    end
    alias_method :with, :curry

    # @api public
    def curried?
      curry_args.size > 0
    end

    # @api public
    def combine(*others)
      Graph.new(self, others)
    end

    # @api private
    def lazy?
      false
    end

    # @api private
    def graph?
      false
    end

    # @api private
    def one?
      result.equal?(:one)
    end

    # @api private
    def many?
      result.equal?(:many)
    end

    # @api private
    def new(new_relation)
      self.class.build(new_relation, options.merge(source: relation))
    end

    private

    # @api private
    def composite_class
      Command::Composite
    end
  end
end
