require 'dry/core/class_attributes'

require 'rom/transaction'

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

    defines :adapter

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
    def self.setup(gateway_or_scheme, *args)
      case gateway_or_scheme
      when String
        raise ArgumentError, <<-STRING.gsub(/^ {10}/, '')
          URIs without an explicit scheme are not supported anymore.
          See https://github.com/rom-rb/rom/blob/master/CHANGELOG.md
        STRING
      when Symbol
        klass = class_from_symbol(gateway_or_scheme)

        if klass.instance_method(:initialize).arity == 0
          klass.new
        else
          klass.new(*args)
        end
      else
        if args.empty?
          gateway_or_scheme
        else
          raise ArgumentError, "Can't accept arguments when passing an instance"
        end
      end
    end

    # Get gateway subclass for a specific adapter
    #
    # @param [Symbol] type Adapter identifier
    #
    # @return [Class]
    #
    # @api private
    def self.class_from_symbol(type)
      adapter = ROM.adapters.fetch(type) {
        begin
          require "rom/#{type}"
        rescue LoadError
          raise AdapterLoadError, "Failed to load adapter rom/#{type}"
        end

        ROM.adapters.fetch(type)
      }

      adapter.const_get(:Gateway)
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

    # An adapter-specific migrator for the gateway
    #
    # @param [Object] args
    #   Arguments required by a migrator's constructor along with a gateway
    #
    # @return [ROM::Migrator]
    #
    def migrator(*args)
      adapter_klass  = ROM.adapters.fetch(adapter)
      migrator_klass = adapter_klass.const_get(:Migrator)
      migrator_klass.new(self, *args)
    rescue NameError
      raise MigratorNotPresentError.new(adapter) unless migrator_klass
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

    # Extension hook for adding gateway-specific behavior to a command class
    #
    # This simply returns back the class by default
    #
    # @param [Class] klass The command class
    # @param [Object] _dataset The dataset that will be used with this command class
    #
    # @return [Class]
    #
    # @api public
    def extend_command_class(klass, _dataset)
      klass
    end

    # Schema inference hook
    #
    # Every gateway that supports schema inference should implement this method
    #
    # @return [Array] An array with dataset names
    #
    # @api private
    def schema
      []
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
    # @param [Hash] Transaction options
    # @return The result of yielding the block or +nil+ if
    #         the transaction was rolled back
    #
    # @api public
    def transaction(opts = EMPTY_HASH, &block)
      transaction_runner(opts).run(opts, &block)
    end

    private

    # @api private
    def transaction_runner(_)
      Transaction::NoOp
    end
  end
end
