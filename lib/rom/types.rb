require 'dry-types'

module ROM
  module Types
    include Dry::Types.module

    def self.included(other)
      other.extend(Methods)
      super
    end

    module Methods
      def ForeignKey(relation, type = Types::Int)
        type.meta(foreign_key: true, target: relation)
      end
    end
  end
end
