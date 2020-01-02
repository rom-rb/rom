# frozen_string_literal: true

require 'rom/changeset/pipe'

module ROM
  class Changeset
    # Stateful changesets carry data and can transform it into
    # a different structure compatible with a persistence backend
    #
    # @abstract
    class Stateful < Changeset
      # Default no-op pipe
      EMPTY_PIPE = Pipe.new(use_for_diff: false).freeze

      # @!attribute [r] __data__
      #   @return [Hash] The relation data
      #   @api private
      option :__data__, optional: true

      # @!attribute [r] pipe
      #   @return [Changeset::Pipe] data transformation pipe
      #   @api private
      option :pipe, reader: false, optional: true

      # Define a changeset mapping
      #
      # Subsequent mapping definitions will be composed together
      # and applied in the order they way defined
      #
      # @example Transformation DSL
      #   class NewUser < ROM::Changeset::Create
      #     map do
      #       unwrap :address, prefix: true
      #     end
      #   end
      #
      # @example Using custom block
      #   class NewUser < ROM::Changeset::Create
      #     map do |tuple|
      #       tuple.merge(created_at: Time.now)
      #     end
      #   end
      #
      # @example Multiple mappings (executed in the order of definition)
      #   class NewUser < ROM::Changeset::Create
      #     map do
      #       unwrap :address, prefix: true
      #     end
      #
      #     map do |tuple|
      #       tuple.merge(created_at: Time.now)
      #     end
      #   end
      #
      # @return [Array<Pipe>, Dry::Transformer::Function>]
      #
      # @see https://github.com/dry-rb/dry-transformer
      #
      # @api public
      def self.map(**options, &block)
        if block.parameters.empty?
          pipes << Class.new(Pipe).define!(&block).new(**options)
        else
          pipes << Pipe.new(block, **options)
        end
      end

      # Define a changeset mapping excluded from diffs
      #
      # @see Changeset::Stateful.map
      # @see Changeset::Stateful#extend
      #
      # @return [Array<Pipe>, Dry::Transformer::Function>]
      #
      # @api public
      def self.extend(*, &block)
        if block
          map(use_for_diff: false, &block)
        else
          super
        end
      end

      # Build default pipe object
      #
      # This can be overridden in a custom changeset subclass
      #
      # @return [Pipe]
      def self.default_pipe(context)
        !pipes.empty? ? pipes.map { |p| p.bind(context) }.reduce(:>>) : EMPTY_PIPE
      end

      # @api private
      def self.inherited(klass)
        return if klass == ROM::Changeset

        super
        klass.instance_variable_set(:@__pipes__, pipes.dup)
      end

      # @api private
      def self.pipes
        @__pipes__
      end
      @__pipes__ = EMPTY_ARRAY

      # Pipe changeset's data using custom steps define on the pipe
      #
      # @overload map(*steps)
      #   Apply mapping using built-in transformations
      #
      #   @example
      #     changeset.map(:add_timestamps)
      #
      #   @param [Array<Symbol>] steps A list of mapping steps
      #
      # @overload map(&block)
      #   Apply mapping using a custom block
      #
      #   @example
      #     changeset.map { |tuple| tuple.merge(created_at: Time.now) }
      #
      # @overload map(*steps, &block)
      #   Apply mapping using built-in transformations and a custom block
      #
      #   @example
      #     changeset.map(:add_timestamps) { |tuple| tuple.merge(status: 'published') }
      #
      #   @param [Array<Symbol>] steps A list of mapping steps
      #
      # @return [Changeset]
      #
      # @api public
      def map(*steps, &block)
        extend(*steps, for_diff: true, &block)
      end

      # Pipe changeset's data using custom steps define on the pipe.
      # You should use #map instead except updating timestamp fields.
      # Calling changeset.extend builds a pipe that excludes certain
      # steps for generating the diff. Currently the only place where
      # it is used is update changesets with the `:touch` step, i.e.
      # `changeset.extend(:touch).diff` will exclude `:updated_at`
      # from the diff.
      #
      # @see Changeset::Stateful#map
      #
      # @return [Changeset]
      #
      # @api public
      def extend(*steps, **options, &block)
        if block
          if !steps.empty?
            extend(*steps, **options).extend(**options, &block)
          else
            with(pipe: pipe.compose(Pipe.new(block).bind(self), **options))
          end
        else
          with(pipe: steps.reduce(pipe.with(**options)) { |a, e| a.compose(pipe[e], **options) })
        end
      end

      # Return changeset with data
      #
      # @param [Hash] data
      #
      # @return [Changeset]
      #
      # @api public
      def data(data)
        with(__data__: data)
      end

      # Coerce changeset to a hash
      #
      # This will send the data through the pipe
      #
      # @return [Hash]
      #
      # @api public
      def to_h
        pipe.call(__data__)
      end
      alias_method :to_hash, :to_h

      # Coerce changeset to an array
      #
      # This will send the data through the pipe
      #
      # @return [Array]
      #
      # @api public
      def to_a
        result == :one ? [to_h] : __data__.map { |element| pipe.call(element) }
      end
      alias_method :to_ary, :to_a

      # Commit stateful changeset
      #
      # @see Changeset#commit
      #
      # @api public
      def commit
        command.call(self)
      end

      # Associate a changeset with another changeset or hash-like object
      #
      # @example with another changeset
      #   new_user = users.changeset(name: 'Jane')
      #   new_task = users.changeset(:tasks, title: 'A task')
      #
      #   new_task.associate(new_user, :users)
      #
      # @example with a hash-like object
      #   user = users.users.by_pk(1).one
      #   new_task = users.changeset(:tasks, title: 'A task')
      #
      #   new_task.associate(user, :users)
      #
      # @param [#to_hash, Changeset] other Other changeset or hash-like object
      # @param [Symbol] name The association identifier from schema
      #
      # @api public
      def associate(other, name = Associated.infer_assoc_name(other))
        Associated.new(self, associations: { name => other })
      end

      # Return command result type
      #
      # @return [Symbol]
      #
      # @api private
      def result
        __data__.is_a?(Array) ? :many : :one
      end

      # Return string representation of the changeset
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(#<#{self.class} relation=#{relation.name.inspect} data=#{__data__}>)
      end

      # @api private
      def command_compiler_options
        super.merge(result: result)
      end

      # Data transformation pipe
      #
      # @return [Changeset::Pipe]
      #
      # @api private
      def pipe
        @pipe ||= self.class.default_pipe(self)
      end

      private

      # @api private
      def respond_to_missing?(meth, include_private = false)
        super || __data__.respond_to?(meth)
      end

      # @api private
      def method_missing(meth, *args, &block)
        if __data__.respond_to?(meth)
          response = __data__.__send__(meth, *args, &block)

          if response.is_a?(__data__.class)
            with(__data__: response)
          else
            response
          end
        else
          super
        end
      end
      ruby2_keywords(:method_missing) if respond_to?(:ruby2_keywords, true)
    end
  end
end
