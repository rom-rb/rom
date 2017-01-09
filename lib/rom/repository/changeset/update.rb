module ROM
  class Changeset
    # Changeset specialization for update commands
    #
    # @api public
    class Update < Changeset
      # @!attribute [r] primary_key
      #   @return [Symbol] The name of the relation's primary key attribute
      option :primary_key, reader: true

      # Return true
      #
      # @return [TrueClass]
      #
      # @api public
      def update?
        true
      end

      # Return false
      #
      # @return [FalseClass]
      #
      # @api public
      def create?
        false
      end

      # Return original tuple that this changeset may update
      #
      # @return [Hash]
      #
      # @api public
      def original
        @original ||= relation.fetch(primary_key)
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
      # @return [Hash[
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

      # @api private
      def command
        command_compiler.(:update, relation, mapper: false).curry(to_h) if diff?
      end
    end
  end
end
