module Veritas

  # Raised when passing an +uri+ with an unregistered scheme to {Adapter.new}
  UnknownAdapterError = Class.new(StandardError)

  # Provides base functionality for every veritas adapter
  #
  # @todo think about making this a (base) class
  #
  # @example
  #
  #   class MyAdapter
  #     extend Veritas::Adapter
  #     uri_scheme :foo
  #   end
  #
  module Adapter

    # The registry of adapters
    #
    # @return [Hash<String, Object>]
    #   a hash of adapters, keyed by uri scheme
    #
    # @api private
    REGISTRY = {}

    # Return the adapter to use for the given +uri+
    #
    # @param [Addressable::URI] uri
    #   the uri to initialize the adapter with
    #
    # @return [Object]
    #   a veritas adapter
    #
    # @raise [UnknownAdapterError]
    #   when the given +uri+'s scheme is not registered
    #
    # @api private
    def self.new(uri)
      get(uri).new(uri)
    end

    # Return the adapter class registered for +uri+
    #
    # @param [Addressable::URI] uri
    #   the uri that identifies the adapter class
    #
    # @return [Class]
    #   a veritas adapter class
    #
    # @raise [UnknownAdapterError]
    #   when the given +uri+'s scheme is not registered
    #
    # @api private
    def self.get(uri)
      uri_scheme = uri.scheme
      REGISTRY.fetch(uri_scheme) {
        raise UnknownAdapterError, "'#{uri_scheme}' is no registered uri scheme"
      }
    end

    # Set the uri scheme for an adapter class
    #
    # @example for a DataObjects adapter
    #
    #   class Postgres < Veritas::Adapter::DataObjects
    #     uri_scheme :postgres
    #   end
    #
    # @example for an arbitrary adapter
    #
    #   class InMemory
    #     extend Veritas::Adapter
    #     uri_scheme :in_memory
    #   end
    #
    # @param [#to_s] name
    #   the name of the uri scheme
    #
    # @return [self]
    #
    # @api public
    def uri_scheme(name)
      REGISTRY[name.to_s] = self
    end

  end # module Adapter
end # module Veritas
