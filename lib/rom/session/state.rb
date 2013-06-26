module ROM
  class Session

    class State
      include Concord::Public.new(:object)

      class Transient < self
        include Concord::Public.new(:object)
      end

      class Persisted < self
        include Concord::Public.new(:object, :mapper)
      end

      class Updated < self
        include Concord::Public.new(:object, :relation)

        Commited = Class.new(self)

        def commit
          Commited.new(object, relation.update(object))
        end
      end

      class Created < self
        include Concord::Public.new(:object, :relation)

        Commited = Class.new(self)

        def commit
          Commited.new(object, relation.insert(object))
        end
      end

      class Deleted < self
        include Concord::Public.new(:object, :relation)

        Commited = Class.new(self)

        def commit
          Commited.new(object, relation.delete(object))
        end
      end

      def delete(relation)
        if persisted?
          Deleted.new(object, relation)
        else
          raise "cannot delete a transient object"
        end
      end

      def save(relation)
        if persisted?
          Updated.new(object, relation)
        elsif transient?
          Created.new(object, relation)
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
