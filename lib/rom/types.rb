require 'dry-types'

module ROM
  module Types
    include Dry::Types.module

    def self.included(other)
      other.extend(Methods)
      super
    end

    def self.Definition(primitive)
      Dry::Types::Definition.new(primitive)
    end

    def self.Constructor(primitive, &block)
      Types.Definition(primitive).constructor(&block)
    end

    module Methods
      def ForeignKey(relation, type = Types::Int)
        type.meta(foreign_key: true, target: relation)
      end
    end
  end
end
