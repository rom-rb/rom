module ROM
  class Session

    class State
      Persisted = Class.new(self) { include Concord::Public.new(:object, :tuple) }
      Updated   = Class.new(self) { include Concord::Public.new(:object, :tuple) }
      Created   = Class.new(self) { include Concord::Public.new(:object) }
      Deleted   = Class.new(self) { include Concord::Public.new(:object) }
      Transient = Class.new(self) { include Concord::Public.new(:object) }

      def delete
        if persisted?
          Deleted.new(object)
        else
          raise "cannot delete a transient object"
        end
      end

      def save
        if persisted?
          Updated.new(object, tuple)
        elsif transient?
          Created.new(object)
        else
          raise "[State#save] unsupported state change from #{self.class}"
        end
      end

      def updated?
        instance_of?(Updated)
      end

      def created?
        instance_of?(Created)
      end

      def persisted?
        instance_of?(Persisted)
      end

      def transient?
        instance_of?(Transient)
      end

      def deleted?
        instance_of?(Deleted)
      end

    end # State

  end # Session
end # ROM
