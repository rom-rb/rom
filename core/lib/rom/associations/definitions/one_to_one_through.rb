require 'rom/associations/definitions/abstract'

module ROM
  module Associations
    module Definitions
      # @api private
      class OneToOneThrough < ManyToMany
        result :one
      end
    end
  end
end
