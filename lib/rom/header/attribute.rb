module ROM
  class Header
    # @private
    class Attribute
      include Equalizer.new(:name, :key, :type)

      attr_reader :name, :key, :meta

      def self.[](meta)
        type = meta[:type]

        if type.equal?(:hash)
          meta[:wrap] ? Wrap : Hash
        elsif type.equal?(:array)
          meta[:group] ? Group : Array
        else
          self
        end
      end

      def self.coerce(input)
        name = input[0]
        meta = (input[1] || {}).dup

        meta[:type] ||= :object

        if meta.key?(:header)
          meta[:header] = Header.coerce(meta[:header], meta[:model])
        end

        self[meta].new(name, meta)
      end

      def initialize(name, meta)
        @name = name
        @meta = meta
        @key = meta.fetch(:from) { name }
      end

      def type
        meta.fetch(:type)
      end

      def typed?
        type != :object
      end

      def aliased?
        key != name
      end

      def mapping
        { key => name }
      end
    end

    class Embedded < Attribute
      include Equalizer.new(:name, :key, :type, :header)

      def header
        meta.fetch(:header)
      end

      def tuple_keys
        header.tuple_keys
      end
    end

    Array = Class.new(Embedded)
    Hash = Class.new(Embedded)
    Wrap = Class.new(Hash)
    Group = Class.new(Array)
  end
end
