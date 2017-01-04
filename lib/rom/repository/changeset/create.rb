module ROM
  class Changeset
    # Changeset specialization for create commands
    #
    # @api public
    class Create < Changeset
      # @!attribute [r] association
      #   @return [Array] Associated changesets with its association name
      option :association, reader: true, optional: true

      # @api public
      def associate(other, assoc)
        with(association: [other, assoc])
      end

      # Return false
      #
      # @return [FalseClass]
      #
      # @api public
      def update?
        false
      end

      # Return true
      #
      # @return [TrueClass]
      #
      # @api public
      def create?
        true
      end

      # @api private
      def command(repo, opts = {})
        if options[:association]
          other, assoc = options[:association]

          if other.is_a?(Changeset)
            repo.command(:create, relation, opts.merge(mapper: false)).
              curry(to_h) >> other.command(repo, use: { associates: proc { associates(assoc) }})
          else
            repo.command(:create, relation, use: { associates: proc { associates(assoc) }}).
              curry(to_h, other.to_h)
          end
        else
          repo.command(:create, relation, opts.merge(mapper: false)).curry(to_h)
        end
      end
    end
  end
end
