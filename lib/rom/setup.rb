require 'rom/support/configurable'

require 'rom/setup/finalize'
require 'rom/support/deprecations'

module ROM
  # Exposes DSL for defining relations, mappers and commands
  #
  # @api public
  class Setup
    include Configurable

    extend Deprecations
    include Equalizer.new(:gateways, :container)

    # @return [Hash] configured gateways
    #
    # @api private
    attr_reader :gateways

    # Deprecated accessor for gateways.
    #
    # @see gateways
    deprecate :repositories, :gateways

    # @return [Symbol] default (first) adapter
    #
    # @api private
    attr_reader :default_adapter

    # @return [Array] registered relation subclasses
    #
    # @api private
    attr_reader :relation_classes

    # @return [Array] registered mapper subclasses
    #
    # @api private
    attr_reader :mapper_classes

    # @return [Array] registered command subclasses
    #
    # @api private
    attr_reader :command_classes

    # @return [Conainer] finalized container after setup phase is over
    #
    # @api private
    attr_reader :container
    alias_method :env, :container

    # @api private
    def initialize(gateways, default_adapter = nil)
      @gateways = gateways
      @default_adapter = default_adapter
      @relation_classes = []
      @mapper_classes = []
      @command_classes = []
      @container = nil
    end

    # Finalize the setup
    #
    # @return [Container] frozen container with access to gateways,
    #                relations, mappers and commands
    #
    # @api public
    def finalize
      raise EnvAlreadyFinalizedError if container

      # initialize default configs for all gateways
      gateways.each_key do |key|
        gateway_config = config.gateways[key]

        gateway_config.infer_schema = true unless gateway_config.key?(:infer_schema)
      end

      finalize = Finalize.new(
        gateways, relation_classes, mapper_classes, command_classes, config.freeze
      )

      @container = finalize.run!
    end

    # Return gateway identified by name
    #
    # @return [Gateway]
    #
    # @api private
    def [](name)
      gateways.fetch(name)
    end

    # Relation sub-classes are being registered with this method during setup
    #
    # @api private
    def register_relation(klass)
      @relation_classes << klass
    end

    # Mapper sub-classes are being registered with this method during setup
    #
    # @api private
    def register_mapper(klass)
      @mapper_classes << klass
    end

    # Command sub-classes are being registered with this method during setup
    #
    # @api private
    def register_command(klass)
      @command_classes << klass
    end

    # Hook for respond_to? used internally
    #
    # @api private
    def respond_to_missing?(name, _include_context = false)
      gateways.key?(name)
    end

    private

    # Returns gateway if method is a name of a registered gateway
    #
    # @return [Gateway]
    #
    # @api private
    def method_missing(name, *)
      gateways.fetch(name) { super }
    end
  end
end
