module ROM
  class Session
    # Object persistance state
    class State
      include Adamantium::Flat, Concord.new(:mapper, :object)

      public :object, :mapper

      # Return identity
      #
      # @return [Object]
      #
      # @api private
      def identity
        dumper.identity
      end
      memoize :identity, :freezer => :noop

      # Return tuple
      #
      # @return [#[]]
      #
      # @api private
      def tuple
        dumper.tuple
      end
      memoize :tuple, :freezer => :noop

      # Perform delete
      #
      # @return [self]
      #
      # @api private
      def delete
        mapper.delete(Operand.new(self))
        self
      end

      # Perform insert
      #
      # @return [self]
      #
      # @api private
      def insert
        mapper.insert(Operand.new(self))
        self
      end

      # Perform update
      #
      # @param [State] old
      #   the old state to be updated
      #
      # @return [self]
      #
      # @api private
      def update(old)
        if dirty?(old)
          mapper.update(Operand::Update.new(self, old.tuple))
        end

        self
      end

      # Test if old state is dirty
      #
      # @param [State] old
      #   the old state to be examined
      #
      # @return [true]
      #   if old state is dirty
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      def dirty?(old)
        tuple != old.tuple
      end

    private

      # Return dumper
      #
      # @return [Dumper]
      #
      # @api private
      def dumper
        mapper.dumper(object)
      end
      memoize :dumper, :freezer => :noop

      # State for loaded objects
      class Loaded < self
        include Concord.new(:loader)

        # Return identity
        #
        # @return [Object]
        #
        # @api private
        def identity
          loader.identity
        end

        # Return mapper
        #
        # @return [Mapper]
        #
        # @api private
        def mapper
          loader.mapper
        end

        # Return tuple
        #
        # @return [#[]]
        #
        # @api private
        def tuple
          loader.tuple
        end

        # Return object
        #
        # @return [Object]
        #
        # @api private
        def object
          loader.object
        end

      end

    end
  end
end
