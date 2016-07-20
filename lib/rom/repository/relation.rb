require 'rom/repository/changeset'
require 'rom/types'

module ROM
  # TODO: these APIs are candidates for inclusion into rom core
  class Relation
    # @api public
    def changeset(*args)
      ROM.Changeset(self, *args)
    end

    # @api private
    def schema_hash
      @schema_hash ||=
        begin
          if schema?
            Types::Coercible::Hash.schema(schema.attributes)
          else
            Hash
          end
        end
    end
  end
end
