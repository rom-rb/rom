module ROM
  class Session

    class State
      include Concord::Public.new(:object)

      Persisted = Class.new(self) { include Concord::Public.new(:object, :tuple) }
      Updated   = Class.new(Persisted)
      Deleted   = Class.new(self) { include Concord::Public.new(:object, :relation) }
      Created   = Class.new(self)
      Transient = Class.new(self)

      class Deleted < self
        def commit
          relation.delete(object)
        end
      end

      def delete(relation)
        if persisted?
          Deleted.new(object, relation)
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
