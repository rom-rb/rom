# frozen_string_literal: true

require "dry/core/class_attributes"

require_relative "support/notifications"
require_relative "transaction"
require_relative "components/provider"

module ROM
  # Abstract gateway class
  #
  # Every adapter needs to inherit from this class and implement
  # required interface
  #
  # @abstract
  #
  # @api public
  class Gateway
    extend Dry::Core::ClassAttributes
    extend Notifications::Listener

    extend ROM::Provider(:plugin, type: :gateway)

    # @!method self.adapter
    #  Get or set gateway's adapter identifier
    #
    #  @overload adapter
    #    Return adapter identifier
    #    @return [Symbol]
    #
    #  @overload gateway(adapter)
    #    @example
    #      class MyGateway < ROM::Gateway
    #        config.component.adapter = :my_adapter
    #      end
    #
    #    @param [Symbol] adapter The adapter identifier
    defines :adapter

    # @!attribute [r] config
    #   @return [Configurable::Config] Gateway's configuration identifier
    attr_reader :config

    # @!attribute [r] connection
    #   @return [Object] The gateway's connection object (type varies across adapters)
    attr_reader :connection

    # Set up a gateway
    #
    # @overload setup(type, *args)
    #   Sets up a single-gateway given a gateway type.
    #   For custom gateways, create an instance and pass it directly.
    #
    #   @example
    #     module SuperDB
    #       class Gateway < ROM::Gateway
    #         def initialize(options)
    #         end
    #       end
    #     end
    #
    #     ROM.register_adapter(:super_db, SuperDB)
    #
    #     Gateway.setup(:super_db, some: 'options')
    #     # SuperDB::Gateway.new(some: 'options') is called
    #
    #   @param [Symbol] type Registered gateway identifier
    #   @param [Array] args Additional gateway options
    #
    # @overload setup(gateway)
    #   Set up a gateway instance
    #
    #   @example
    #     module SuperDB
    #       class Gateway < ROM::Gateway
    #         def initialize(options)
    #         end
    #       end
    #     end
    #
    #     ROM.register_adapter(:super_db, SuperDB)
    #
    #     Gateway.setup(SuperDB::Gateway.new(some: 'options'))
    #
    #   @param [Gateway] gateway
    #
    # @return [Gateway] a specific gateway subclass
    #
    # @api public
    #
    # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
    def self.setup(gateway_or_scheme, *args)
      case gateway_or_scheme
      when Gateway
        unless args.empty?
          raise ArgumentError, "Can't accept arguments when passing an instance"
        end

        gateway_or_scheme
      when String
        raise ArgumentError, <<-STRING.gsub(/^ {10}/, "")
          URIs without an explicit scheme are not supported anymore.
          See https://github.com/rom-rb/rom/blob/main/CHANGELOG.md
        STRING
      when Symbol
        klass = class_from_symbol(gateway_or_scheme)

        if klass.instance_method(:initialize).arity.zero?
          klass.new
        elsif args.size.equal?(1) && args.first.respond_to?(:args)
          if args.first.respond_to?(:args)
            setup(gateway_or_scheme, *args.first.args)
          else
            klass.new(**config)
          end
        elsif args.last.is_a?(Hash)
          klass.new(*args[0..-2], **args.last)
        else
          klass.new(*args)
        end
      else
        gateway_or_scheme
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

    class << self
      ruby2_keywords(:setup) if respond_to?(:ruby2_keywords, true)
    end

    # Get gateway subclass for a specific adapter
    #
    # @param [Symbol] type Adapter identifier
    #
    # @return [Class]
    #
    # @api private
    def self.class_from_symbol(type)
      adapter = ROM.adapters.fetch(type) do
        begin
          require "rom/#{type}"
        rescue LoadError
          raise AdapterLoadError, "Failed to load adapter rom/#{type}"
        end

        ROM.adapters.fetch(type)
      end

      adapter.const_get(:Gateway)
    end

    # Configured gateway name used in the registry
    #
    # @return [Symbol]
    #
    # @api public
    def name
      config.id
    end

    # Returns the adapter, defined for the class
    #
    # @return [Symbol]
    #
    # @api public
    def adapter
      self.class.adapter || raise(
        MissingAdapterIdentifierError,
        "gateway class +#{self}+ is missing the adapter identifier"
      )
    end

    # A generic interface for setting up a logger
    #
    # This is not a required interface, it's a no-op by default
    #
    # @abstract
    #
    # @api public
    def use_logger(*)
      # noop
    end

    # A generic interface for returning default logger
    #
    # Adapters should implement this method as handling loggers is different
    # across adapters. This is a no-op by default and returns nil.
    #
    # @return [NilClass]
    #
    # @api public
    def logger
      # noop
    end

    # Disconnect is optional and it's a no-op by default
    #
    # @api public
    def disconnect
      # noop
    end

    # Runs a block inside a transaction. The underlying transaction engine
    # is adapter-specific
    #
    # @param [Hash] opts Transaction options
    #
    # @return The result of yielding the block or +nil+ if
    #         the transaction was rolled back
    #
    # @api public
    def transaction(**opts, &block)
      transaction_runner(**opts).run(**opts, &block)
    end

    # Build a command instance
    #
    # @return [Command]
    #
    # @api public
    def command(klass, relation:, **opts)
      klass.build(relation, **opts)
    end

    private

    # @api private
    def transaction_runner(**)
      Transaction::NoOp
    end
  end
end
