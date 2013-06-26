module ROM
  class Session

    class State
      include Concord::Public.new(:object)

      TransitionError = Class.new(StandardError)

      class Transient < self
        include Concord::Public.new(:object)

        def save(relation)
          Created.new(object, relation)
        end
      end # Transient

      class Persisted < self
        include Concord::Public.new(:object, :mapper)

        def save(relation)
          if mapper.dirty?(object)
            Updated.new(object, relation)
          else
            self
          end
        end

        def delete(relation)
          Deleted.new(object, relation)
        end
      end # Persisted

      class Updated < self
        include Concord::Public.new(:object, :relation)

        Commited = Class.new(self)

        def commit
          Commited.new(object, relation.update(object))
        end
      end # Updated

      class Created < self
        include Concord::Public.new(:object, :relation)

        Commited = Class.new(self)

        def commit
          Commited.new(object, relation.insert(object))
        end
      end # Created

      class Deleted < self
        include Concord::Public.new(:object, :relation)

        Commited = Class.new(self)

        def commit
          Commited.new(object, relation.delete(object))
        end
      end # Deleted

      def save(*)
        raise TransitionError, "cannot save object with #{self.class} state"
      end

      def delete(*)
        raise TransitionError, "cannot delete object with #{self.class} state"
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
