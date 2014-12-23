module ROM
  class Header
    # @private
    class Attribute
      include Equalizer.new(:name, :key, :type)

      attr_reader :name, :key, :meta

      class Embedded < Attribute
        include Equalizer.new(:name, :type, :model, :header)

        def model
          meta[:model]
        end

        def header
          meta.fetch(:header)
        end

        def mapping
          header.mapping
        end

        def embedded?
          true
        end

        def transform?
          meta.fetch(:transform)
        end
      end

      def self.[](type)
        if type == Array || type == Hash
          Embedded
        else
          self
        end
      end

      def self.coerce(input)
        if input.is_a?(self)
          input
        else
          name = input[0]
          meta = (input[1] || {}).dup

          meta[:type] ||= Object
          meta[:transform] ||= false
          meta[:header] = Header.coerce(meta[:header]) if meta.key?(:header)

          self[meta[:type]].new(name, meta)
        end
      end

      def initialize(name, meta = {})
        @name = name
        @meta = meta
        @key = meta.fetch(:from) { name }
      end

      def type
        meta.fetch(:type)
      end

      def aliased?
        key != name
      end

      def embedded?
        false
      end

      def transform?
        false
      end

      def mapping
        [key, name]
      end
    end
  end
end
