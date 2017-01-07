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

    # @!attribute [r] data
    #   @return [Hash] The relation data
    option :data, reader: true, optional: true

    # @!attribute [r] pipe
    #   @return [Changeset::Pipe] data transformation pipe
    option :pipe, reader: true, accept: [Proc, Pipe], default: -> changeset {
      changeset.class.default_pipe
    }

    # @!attribute [r] command_compiler
    #   @return [Proc] a proc that can compile a command (typically provided by a repo)
    option :command_compiler, reader: true, optional: true

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
      fetch_or_store(relation_name) {
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
    def map(*steps)
      with(pipe: steps.reduce(pipe) { |a, e| a >> pipe[e] })
    end

    # Coerce changeset to a hash
    #
    # This will send the data through the pipe
    #
    # @return [Hash]
    #
    # @api public
    def to_h
      pipe.call(data)
    end
    alias_method :to_hash, :to_h

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

    private

    # @api private
    def respond_to_missing?(meth, include_private = false)
      super || data.respond_to?(meth)
    end

    # @api private
    def method_missing(meth, *args, &block)
      if data.respond_to?(meth)
        response = data.__send__(meth, *args, &block)

        if response.is_a?(Hash)
          self.class.new(relation, options.merge(data: response))
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
