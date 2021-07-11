# frozen_string_literal: true

require "dry/configurable"

require "rom/types"
require "rom/initializer"
require "rom/pipeline"
require "rom/components"

require "rom/commands/class_interface"
require "rom/commands/composite"
require "rom/commands/graph"
require "rom/commands/lazy"

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
  # @api public
  class Command
    extend ROM.Components
    extend Dry::Configurable
    extend Initializer
    extend ClassInterface

    include Dry::Equalizer(:relation, :options)
    include Commands
    include Pipeline::Operator

    setting :restrictable
    setting :result
    setting :input
    setting :type

    setting :component do
      setting :id
      setting :relation_id
      setting :adapter
      setting :namespace, default: -> (config) { "commands.#{config.component.relation_id}" }
    end

    config.input = Hash
    config.result = :many

    # @!attribute [r] relation
    #   @return [Relation] Command's relation
    param :relation

    CommandType = Types::Strict::Symbol.enum(:create, :update, :delete)
    Result = Types::Strict::Symbol.enum(:one, :many)

    # @!attribute [r] type
    #   @return [Symbol] The command type, one of :create, :update or :delete
    option :type, type: CommandType, optional: true

    # @!attribute [r] config
    #   @return [Dry::Configurable::Config]
    option :config, default: -> { self.class.config }

    # @!attribute [r] source
    #   @return [Relation] The source relation
    option :source, default: -> { relation }

    # @!attribute [r] result
    #   @return [Symbol] Result type, either :one or :many
    option :result, type: Result, default: -> { config.result }

    # @!attribute [r] input
    #   @return [Proc, #call] Tuple processing function, typically uses Relation#input_schema
    option :input, default: -> { config.input }

    # @!attribute [r] curry_args
    #   @return [Array] Curried args
    option :curry_args, default: -> { EMPTY_ARRAY }

    # @!attribute [r] before
    #   @return [Array<Hash>] An array with before hooks configuration
    option :before, Types::Coercible::Array, reader: false, default: -> { self.class.before }

    # @!attribute [r] after
    #   @return [Array<Hash>] An array with after hooks configuration
    option :after, Types::Coercible::Array, reader: false, default: -> { self.class.after }

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
    # This method will apply before/after hooks automatically
    #
    # @api public
    def call(*args, &block)
      tuples =
        if hooks?
          prepared =
            if curried?
              apply_hooks(before_hooks, *(curry_args + args))
            else
              apply_hooks(before_hooks, *args)
            end

          result = prepared ? execute(prepared, &block) : execute(&block)

          if curried?
            if !args.empty?
              apply_hooks(after_hooks, result, *args)
            elsif curry_args.size > 1
              apply_hooks(after_hooks, result, curry_args[1])
            else
              apply_hooks(after_hooks, result)
            end
          else
            apply_hooks(after_hooks, result, *args[1..args.size - 1])
          end
        else
          execute(*(curry_args + args), &block)
        end

      if one?
        tuples.first
      else
        tuples
      end
    end
    alias_method :[], :call

    # Curry this command with provided args
    #
    # Curried command can be called without args. If argument is a graph input processor,
    # lazy command will be returned, which is used for handling nested input hashes.
    #
    # @return [Command, Lazy]
    #
    # @api public
    def curry(*args)
      if curry_args.empty? && args.first.is_a?(Graph::InputEvaluator)
        Lazy[self].new(self, *args)
      else
        self.class.build(relation, **options, curry_args: args)
      end
    end

    # Compose this command with other commands
    #
    # Composed commands can handle nested input
    #
    # @return [Command::Graph]
    #
    # @api public
    def combine(*others)
      Graph.new(self, others)
    end

    # Check if this command is curried
    #
    # @return [TrueClass, FalseClass]
    #
    # @api public
    def curried?
      !curry_args.empty?
    end

    # Return a new command with appended before hooks
    #
    # @param [Array<Hash>] hooks A list of before hooks configurations
    #
    # @return [Command]
    #
    # @api public
    def before(*hooks)
      self.class.new(relation, **options, before: before_hooks + hooks)
    end

    # Return a new command with appended after hooks
    #
    # @param [Array<Hash>] hooks A list of after hooks configurations
    #
    # @return [Command]
    #
    # @api public
    def after(*hooks)
      self.class.new(relation, **options, after: after_hooks + hooks)
    end

    # List of before hooks
    #
    # @return [Array]
    #
    # @api public
    def before_hooks
      options[:before]
    end

    # List of after hooks
    #
    # @return [Array]
    #
    # @api public
    def after_hooks
      options[:after]
    end

    # Return a new command with other source relation
    #
    # This can be used to restrict command with a specific relation
    #
    # @return [Command]
    #
    # @api public
    def new(new_relation)
      self.class.build(new_relation, **options, source: relation)
    end

    # Check if this command has any hooks
    #
    # @api private
    def hooks?
      !before_hooks.empty? || !after_hooks.empty?
    end

    # Check if this command is lazy
    #
    # @return [false]
    #
    # @api private
    def lazy?
      false
    end

    # Check if this command is a graph
    #
    # @return [false]
    #
    # @api private
    def graph?
      false
    end

    # Check if this command returns a single tuple
    #
    # @return [TrueClass,FalseClass]
    #
    # @api private
    def one?
      result.equal?(:one)
    end

    # Check if this command returns many tuples
    #
    # @return [TrueClass,FalseClass]
    #
    # @api private
    def many?
      result.equal?(:many)
    end

    # Check if this command is restrictible through relation
    #
    # @return [TrueClass,FalseClass]
    #
    # @api private
    def restrictible?
      config.restrictable.equal?(true)
    end

    # Yields tuples for insertion or return an enumerator
    #
    # @api private
    def map_input_tuples(tuples, &mapper)
      return enum_for(:with_input_tuples, tuples) unless mapper

      if tuples.respond_to? :merge
        mapper[tuples]
      else
        tuples.map(&mapper)
      end
    end

    private

    # Hook called by Pipeline to get composite class for commands
    #
    # @return [Class]
    #
    # @api private
    def composite_class
      Command::Composite
    end

    # Apply provided hooks
    #
    # Used by #call
    #
    # @return [Array<Hash>]
    #
    # @api private
    def apply_hooks(hooks, tuples, *args)
      hooks.reduce(tuples) do |a, e|
        if e.is_a?(Hash)
          hook_meth, hook_args = e.to_a.flatten(1)
          __send__(hook_meth, a, *args, **hook_args)
        else
          __send__(e, a, *args)
        end
      end
    end

    # Pipes a dataset through command's relation
    #
    # @return [Array]
    #
    # @api private
    def wrap_dataset(dataset)
      if relation.is_a?(Relation::Composite)
        relation.new(dataset).to_a
      else
        dataset
      end
    end
  end
end
