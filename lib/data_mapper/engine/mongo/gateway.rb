module DataMapper
  class Engine
    module Mongo

      class Gateway
        include Enumerable

        # Returns name of the wrapped collection
        #
        # @api private
        attr_reader :name

        # Returns wrapped collection. This can be a base collection or a "virtual" one
        #
        # @api private
        attr_reader :collection

        # Initializes a gateway instance
        #
        # @api private
        def initialize(name, collection)
          @name       = name.to_sym
          @collection = collection
        end

        # Iterates over rows returned by the wrapped collection
        #
        # @api public
        def each(&block)
          return to_enum unless block_given?
          collection.find.each(&block)
          self
        end

        # Inserts a new row
        #
        # @param [Hash] tuple
        #
        # @api public
        def insert(document)
          raise NotImplementedError
        end

        # Deletes a row matching given criteria
        #
        # @api public
        def delete(conditions)
          raise NotImplementedError
        end

      end # class Gateway

    end # module Mongo
  end # class Engine
end # module DataMapper
