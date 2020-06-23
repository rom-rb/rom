# frozen_string_literal: true

require "rom/relation/graph"

module ROM
  class Changeset
    # Namespace for changeset extensions
    #
    # @api public
    module Extensions
      # Changeset extenions for combined relations
      #
      # @api public
      class Relation::Graph
        # Build a changeset for a combined relation
        #
        # @raise NotImplementedError
        #
        # @api public
        def changeset(*)
          raise NotImplementedError, "Changeset doesn't support combined relations yet"
        end
      end
    end
  end
end
