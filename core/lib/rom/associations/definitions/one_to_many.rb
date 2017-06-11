require 'rom/associations/definitions/abstract'

module ROM
  module Associations
    module Definitions
      class OneToMany < Abstract
        result :many
      end
    end
  end
end
