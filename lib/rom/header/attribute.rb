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

      def t(*args)
        Transproc(*args)
      end

      def type
        meta.fetch(:type)
      end

      def aliased?
        key != name
      end

      def to_transproc
        nil
      end

      def preprocessor
        nil
      end

      def mapping
        { key => name }
      end
    end
  end
end
