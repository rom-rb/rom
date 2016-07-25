require 'rom/support/constants'
require 'rom/support/options'

require 'rom/repository/changeset/pipe'

module ROM
  def self.Changeset(*args)
    if args.size == 2
      relation, data = args
    elsif args.size == 3
      relation, pk, data = args
    else
      raise ArgumentError, 'ROM.Changeset accepts 2 or 3 arguments'
    end

    if pk
      Changeset::Update.new(relation, data, primary_key: pk)
    else
      Changeset::Create.new(relation, data)
    end
  end

  class Changeset
    include Options

    # @!attribute [r] pipe
    #   @return [Changeset::Pipe] data transformation pipe
    option :pipe, reader: true, accept: [Proc, Pipe], default: -> changeset {
      changeset.class.default_pipe
    }

    # @!attribute [r] relation
    #   @return [Relation] The changeset relation
    attr_reader :relation

    # @!attribute [r] data
    #   @return [Hash] The relation data
    attr_reader :data

    # Build default pipe object
    #
    # This can be overridden in a custom changeset subclass
    #
    # @return [Pipe]
    def self.default_pipe
      Pipe.new
    end

    # @api private
    def initialize(relation, data, options = EMPTY_HASH)
      @relation = relation
      @data = data
      super
    end

    # Pipe changeset's data using custom steps define on the pipe
    #
    # @param *steps [Array<Symbol>] A list of mapping steps
    #
    # @return [Changeset]
    #
    # @api public
    def map(*steps)
      with(pipe: steps.reduce(pipe) { |a, e| a >> pipe.class[e] })
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
      self.class.new(relation, data, options.merge(new_options))
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
          self.class.new(relation, response, options)
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
