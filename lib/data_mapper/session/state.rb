module DataMapper
  class Session
    # Represent an object with its mapper
    class State
      include Adamantium::Flat, Equalizer.new(:mapper, :object, :identity, :tuple)

      # Return mapper
      #
      # @return [Mapper]
      #
      # @api private
      #
      attr_reader :mapper

      # Return object
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :object

      # Return identity
      #
      # @return [Identity]
      #
      # @api private
      #
      def identity
        dumper.identity
      end
      memoize :identity, :freezer => :noop

      # Return tuple
      #
      # @return [Tuple]
      #
      # @api private
      #
      def tuple
        dumper.tuple
      end
      memoize :tuple, :freezer => :noop

      # Perform delete
      #
      # @return [self]
      #
      # @api private
      #
      def delete
        mapper.delete(Operand.new(self))
        self
      end

      # Perform insert
      #
      # @return [self]
      #
      # @api private
      #
      def insert
        mapper.insert(Operand.new(self))
        self
      end

      # Perform update
      #
      # @return [self]
      #
      # @api private
      #
      def update(old)
        if dirty?(old)
          mapper.update(Operand::Update.new(self, old.tuple))
        end

        self
      end

      # Test if old state is dirty?
      #
      # @param [State] old
      #
      # @return [true]
      #   if old state is dirty
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def dirty?(old)
        tuple != old.tuple
      end

    private

      # Return dumper
      #
      # @return [Dumper]
      #
      # @api private
      #
      def dumper
        mapper.dumper(object)
      end
      memoize :dumper, :freezer => :noop

      # Initialize object
      #
      # @param [Mapper] mapper
      # @param [Object] object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(mapper, object)
        @mapper, @object = mapper, object
      end

      # State for loaded objects
      class Loaded < self

        # Return identity
        #
        # @return [Identity]
        #
        # @api private
        #
        def identity
          @loader.identity
        end

        # Return mapper
        #
        # @return [Mapper]
        #
        # @api private
        #
        def mapper
          @loader.mapper
        end

        # Return tuple
        #
        # @return [Tuple]
        #
        # @api private
        #
        def tuple
          @loader.tuple
        end

        # Return object
        #
        # @return [Object]
        #
        # @api private
        #
        def object
          @loader.object
        end

        # Initialize object
        #
        # @param [Loader] loader
        #
        # @api private
        #
        def initialize(loader)
          @loader = loader
        end

      end

    end
  end
end
