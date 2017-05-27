require 'rom/repository/changeset/restricted'

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
    # @see Changeset::Stateful
    #
    # @api public
    class Update < Stateful
      include Restricted

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
      # @return [Hash]
      #
      # @api public
      def diff
        @diff ||=
          begin
            data = pipe.for_diff(__data__)
            data_tuple = data.to_a
            data_keys = data.keys & original.keys

            new_tuple = data_tuple.to_a.select { |(k, _)| data_keys.include?(k) }
            ori_tuple = original.to_a.select { |(k, _)| data_keys.include?(k) }

            Hash[new_tuple - (new_tuple & ori_tuple)]
          end
      end
    end
  end
end
