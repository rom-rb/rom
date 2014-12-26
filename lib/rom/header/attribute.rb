module ROM
  class Header
    # @private
    class Attribute
      include Equalizer.new(:name, :key, :type)

      attr_reader :name, :key, :meta

      def self.[](meta)
        type = meta[:type]

        if type == ::Hash
          meta[:wrap] ? Wrap : Hash
        elsif type == ::Array
          meta[:group] ? Group : Array
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
          meta[:header] = Header.coerce(meta[:header], meta[:model]) if meta.key?(:header)

          self[meta].new(name, meta)
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

      def preprocess?
        false
      end

      def mapping
        { key => name }
      end
    end

    class Embedded < Attribute
      include Equalizer.new(:name, :type, :header)

      def header
        meta.fetch(:header)
      end
    end

    Array = Class.new(Embedded)
    Hash = Class.new(Embedded)

    class Wrap < Hash
      def preprocess?
        true
      end
    end

    class Group < Array
      def preprocess?
        true
      end
    end
  end
end
