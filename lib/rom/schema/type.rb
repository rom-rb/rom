require 'delegate'
require 'dry/equalizer'
require 'dry/types/decorator'

module ROM
  class Schema
    class Type
      include Dry::Equalizer(:type)

      attr_reader :type

      def initialize(type)
        @type = type
      end

      # @api private
      def [](input)
        type[input]
      end

      # @api private
      def read?
        ! meta[:read].nil?
      end

      def to_read_type
        read? ? meta[:read] : type
      end

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
        meta(alias: name)
      end
      alias_method :as, :aliased

      # @api public
      def prefixed(prefix = source.dataset)
        aliased(:"#{prefix}_#{name}")
      end

      # @api public
      def wrapped?
        meta[:wrapped].equal?(true)
      end

      # @api public
      def wrapped(name = source.dataset)
        self.class.new(prefixed(name).meta(wrapped: true))
      end

      # @api public
      def meta(opts = nil)
        if opts
          self.class.new(type.meta(opts))
        else
          type.meta
        end
      end

      # @api public
      def inspect
        %(#<#{self.class}[#{type.name}] #{meta.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>)
      end
      alias_method :pretty_inspect, :inspect

      # @api public
      def eql?(other)
        other.is_a?(self.class) ? super : type.eql?(other)
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        type.respond_to?(name) || super
      end

      private

      # @api private
      def method_missing(meth, *args, &block)
        if type.respond_to?(meth)
          response = type.__send__(meth, *args, &block)

          if response.is_a?(type.class)
            self.class.new(type)
          else
            response
          end
        else
          super
        end
      end
    end
  end
end
