module ROM
  class Changeset
    # Changeset specialization for update commands
    #
    # Update changesets will only execute their commands when
    # the data is different from the original tuple. Original tuple
    # is fetched from changeset's relation using `by_pk` relation view.
    # This means the underlying adapter must provide this view, or you
    # you need to implement it yourself in your relations if you want to
    # use Update changesets.
    #
    # @api public
    class Update < Stateful
      command_type :update

      # Commit update changeset if there's a diff
      #
      # This returns original tuple if there's no diff
      #
      # @return [Hash]
      #
      # @see Changeset#commit
      #
      # @api public
      def commit
        diff? ? super : original
      end

      # Return original tuple that this changeset may update
      #
      # @return [Hash]
      #
      # @api public
      def original
        @original ||= Hash(relation.one)
      end

      # Return diff hash sent through the pipe
      #
      # @return [Hash]
      #
      # @api public
      def to_h
        pipe.call(diff)
      end
      alias_method :to_hash, :to_h

      # Return true if there's a diff between original and changeset data
      #
      # @return [TrueClass, FalseClass]
      #
      # @api public
      def diff?
        ! diff.empty?
      end

      # Return if there's no diff between the original and changeset data
      #
      # @return [TrueClass, FalseClass]
      #
      # @api public
      def clean?
        diff.empty?
      end

      # Calculate the diff between the original and changeset data
      #
      # @return [Hash, Array]
      #
      # @api public
      def diff
        @diff ||=
          begin
            new_tuple = __data__.to_a
            ori_tuple = original.to_a

            Hash[new_tuple - (new_tuple & ori_tuple)]
          end
      end

      # Return a command for this changesets if there's a diff
      #
      # @see Changeset#command
      #
      # @api public
      def command
        super.curry(to_h) if diff?
      end

      # @api private
      def default_command_type
        :update
      end
    end
  end
end
