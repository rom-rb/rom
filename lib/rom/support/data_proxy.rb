module ROM
  # Helper module for dataset classes
  #
  # It provides a constructor accepting data, header and an optional row_proc.
  # This module is used internally by EnumerableDataset and ArrayDataset.
  #
  # @private
  module DataProxy
    NON_FORWARDABLE = [
      :each, :to_a, :to_ary, :kind_of?, :instance_of?, :is_a?
    ].freeze

    # @return [Object] Data object for the iterator
    #
    # @api private
    attr_reader :data

    # @return [Proc] tuple processing proc
    #
    # @api private
    attr_reader :row_proc

    # Extends the class with `forward` DSL and Equalizer using `data` attribute
    #
    # @see ClassMethods#forward
    #
    # @api private
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        include Equalizer.new(:data)
      end
    end

    # Constructor for dataset objects
    #
    # @param [Object] data
    # @param [Array<Symbol>] tuple attribute names
    # @param [Proc] tuple processing proc
    #
    # @api private
    def initialize(data, row_proc = self.class.row_proc)
      @data = data
      @row_proc = row_proc
    end

    # Iterate over data using row_proc
    #
    # @return [Enumerator] if block is not given
    #
    # @api private
    def each
      return to_enum unless block_given?
      data.each { |tuple| yield(row_proc[tuple]) }
    end

    module ClassMethods
      # Default no-op tuple proc
      #
      # @return [Proc]
      #
      # @api private
      def row_proc
        -> tuple { tuple }
      end

      # Forward provided methods to the underlaying data object
      #
      # @example
      #
      #   class MyDataset
      #     include DataProxy
      #
      #     forward(:find_all, :map)
      #   end
      #
      # @return [undefined]
      #
      # @api public
      def forward(*methods)
        # FIXME: we should probably raise if one of the non-forwardable methods
        #       was provided
        (Array(methods).flatten - NON_FORWARDABLE).each do |method_name|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(*args, &block)
              response = data.public_send(#{method_name.inspect}, *args, &block)

              if response.equal?(data)
                self
              elsif response.is_a?(data.class)
                self.class.new(response)
              else
                response
              end
            end
          RUBY
        end
      end
    end
  end
end
