require 'rom/types'
require 'rom/associations/definitions/abstract'

module ROM
  module Associations
    module Definitions
      class ManyToMany < Abstract
        result :many

        option :through, reader: true, type: Types::Strict::Symbol.optional

        # @api private
        def initialize(*)
          super
          @through = Relation::Name[
            options[:through] || options[:through_relation], options[:through]
          ]
        end
      end
    end
  end
end
