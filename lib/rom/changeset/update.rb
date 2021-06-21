# frozen_string_literal: true

module ROM
  class Changeset
    # Changeset specialization for update commands
    #
    # Update changesets will only execute their commands when
    # the data is different from the original tuple. Original tuple
    # is fetched from changeset's relation using `one` method.
    #
    # @example
    #   users.by_pk(1).changeset(:update, name: "Jane Doe").commit
    #
    # @see Changeset::Stateful
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
        @original ||= relation.one
      end

      # Return true if there's a diff between original and changeset data
      #
      # @return [TrueClass, FalseClass]
      #
      # @api public
      def diff?
        !diff.empty?
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
            source = original.to_h
            data = pipe.for_diff(__data__)
            data_tuple = data.to_a
            data_keys = data.keys & source.keys

            new_tuple = data_tuple.to_a.select { |k, _| data_keys.include?(k) }
            ori_tuple = source.to_a.select { |k, _| data_keys.include?(k) }

            (new_tuple - (new_tuple & ori_tuple)).to_h
          end
      end
    end
  end
end
