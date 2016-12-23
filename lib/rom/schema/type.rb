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
      def aliased?
        !meta[:alias].nil?
      end

      # @api public
      def source
        meta[:source]
      end

      # @api public
      def target
        meta[:target]
      end

      # @api public
      def name
        meta[:name]
      end

      # @api public
      def alias
        meta[:alias]
      end

      # @api public
      def aliased(name)
        self.class.new(type.meta(alias: name))
      end

      # @api public
      def eql?(other)
        other.is_a?(self.class) ? super : type.eql?(other)
      end
    end
  end
end
