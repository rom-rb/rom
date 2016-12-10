require 'delegate'
require 'dry/equalizer'
require 'dry/types/decorator'

module ROM
  class Schema
    class Type < SimpleDelegator
      include Dry::Equalizer(:type)
      alias_method :type, :__getobj__

      # @api public
      def primary_key?
        meta[:primary_key].equal?(true)
      end

      # @api public
      def foreign_key?
        meta[:foreign_key].equal?(true)
      end

      # @api public
      def relation
        meta[:relation]
      end

      # @api public
      def eql?(other)
        other.is_a?(self.class) ? super : type.eql?(other)
      end
    end
  end
end
