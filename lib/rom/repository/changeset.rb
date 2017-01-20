require 'dry/core/class_attributes'
require 'dry/core/cache'

require 'rom/initializer'
require 'rom/repository/changeset/pipe'

module ROM
  class Changeset
    extend Initializer
    extend Dry::Core::Cache
    extend Dry::Core::ClassAttributes

    defines :relation

    # @!attribute [r] relation
    #   @return [Relation] The changeset relation
    param :relation

    # @!attribute [r] __data__
    #   @return [Hash] The relation data
    option :__data__, reader: true, optional: true, default: proc { nil }

    # @!attribute [r] pipe
    #   @return [Changeset::Pipe] data transformation pipe
    option :pipe, reader: true, accept: [Proc, Pipe], default: -> changeset {
      changeset.class.default_pipe
    }

    # @!attribute [r] command_compiler
    #   @return [Proc] a proc that can compile a command (typically provided by a repo)
    option :command_compiler, reader: true, optional: true

    # @!attribute [r] command_type
    #   @return [Symbol] a custom command identifier
    option :command_type, reader: true, optional: true, default: -> changeset { changeset.default_command_type }

    # Create a changeset class preconfigured for a specific relation
    #
    # @example
    #   class NewUserChangeset < ROM::Changeset::Create[:users]
    #   end
    #
    #   user_repo.changeset(NewUserChangeset).data(name: 'Jane')
    #
    # @api public
    def self.[](relation_name)
      fetch_or_store([relation_name, self]) {
        Class.new(self) { relation(relation_name) }
      }
    end

    # @api public
    def self.map(&block)
      @pipe = Class.new(Pipe, &block).new
    end

    # Build default pipe object
    #
    # This can be overridden in a custom changeset subclass
    #
    # @return [Pipe]
    def self.default_pipe
      @pipe || Pipe.new
    end

    # Pipe changeset's data using custom steps define on the pipe
    #
    # @param *steps [Array<Symbol>] A list of mapping steps
    #
    # @return [Changeset]
    #
    # @api public
    def map(*steps, &block)
      if block
        __data__.map { |*args| yield(*args) }
      else
        with(pipe: steps.reduce(pipe) { |a, e| a >> pipe[e] })
      end
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

    # Return a new changeset with updated options
    #
    # @param [Hash] new_options The new options
    #
    # @return [Changeset]
    #
    # @api private
    def with(new_options)
      self.class.new(relation, options.merge(new_options))
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

    # Return command result type
    #
    # @return [Symbol]
    #
    # @api private
    def result
      __data__.is_a?(Hash) ? :one : :many
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
  end
end

require 'rom/repository/changeset/create'
require 'rom/repository/changeset/update'
require 'rom/repository/changeset/delete'
