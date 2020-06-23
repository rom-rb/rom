# frozen_string_literal: true

require "rom/initializer"

module ROM
  class Changeset
    # Associated changesets automatically set up FKs
    #
    # @api public
    class Associated
      extend Initializer

      # @!attribute [r] left
      #   @return [Changeset::Create] Child changeset
      param :left

      # @!attribute [r] associations
      #   @return [Array] List of association identifiers from relation schema
      option :associations

      # Infer association name from an object with a schema
      #
      # This expects other to be an object with a schema that includes a primary key
      # attribute with :source meta information. This makes it work with both structs
      # and relations
      #
      # @see Stateful#associate
      #
      # @api private
      def self.infer_assoc_name(other)
        schema = other.class.schema
        attrs = schema.is_a?(Hash) ? schema.values : schema
        pk = attrs.detect { |attr| attr.meta[:primary_key] }

        if pk
          pk.meta[:source]
        else
          raise ArgumentError, "can't infer association name for #{other}"
        end
      end

      # Commit changeset's composite command
      #
      # @example
      #   task_changeset = tasks.
      #     changeset(title: 'Task One').
      #     associate(user, :user).
      #     commit
      #   # {:id => 1, :user_id => 1, title: 'Task One'}
      #
      # @return [Array<Hash>, Hash]
      #
      # @api public
      def commit
        command.call
      end

      # Associate with other changesets
      #
      # @see Changeset#associate
      #
      # @return [Associated]
      #
      # @api public
      def associate(other, name = Associated.infer_assoc_name(other))
        self.class.new(left, associations: associations.merge(name => other))
      end

      # Create a composed command
      #
      # @example using existing parent data
      #   user_changeset = users.changeset(name: 'Jane')
      #   task_changeset = tasks.changeset(title: 'Task One')
      #
      #   user = users.create(user_changeset)
      #   task = tasks.create(task_changeset.associate(user, :user))
      #
      # @example saving both parent and child in one go
      #   user_changeset = users.changeset(name: 'Jane')
      #   task_changeset = tasks.changeset(title: 'Task One')
      #
      #   task = tasks.create(task_changeset.associate(user, :user))
      #
      # This works *only* with parent => child(ren) changeset hierarchy
      #
      # @return [ROM::Command::Composite]
      #
      # @api public
      def command
        associations.reduce(left.command.curry(left)) do |a, (assoc, other)|
          case other
          when Changeset
            a >> other.command.with_association(assoc).curry(other)
          when Associated
            a >> other.command.with_association(assoc)
          when Array
            raise NotImplementedError, "Changeset::Associate does not support arrays yet"
          else
            a.with_association(assoc, parent: other)
          end
        end
      end

      # @api private
      def relation
        left.relation
      end
    end
  end
end
