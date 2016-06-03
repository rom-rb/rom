require 'rom/repository/changeset'
require 'rom/types'

module ROM
  # TODO: these APIs are candidates for inclusion into rom core
  class Relation
    # @api private
    def changeset(input)
      Repository::Changeset.new(self, input)
    end

    # @api private
    # TODO: might be worth considering a schema hash which does hash conversion
    #       by default so that we can avoid creating a proc here
    def schema_processor
      if schema?
        -> data { schema_hash[Hash[data]] }
      else
        Hash
      end
    end

    # @api private
    def schema_hash
      Types::Hash.schema(schema.attributes)
    end
  end
end
