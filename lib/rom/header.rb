module ROM

  class Header
    include Enumerable
    include Equalizer.new(:attributes)

    attr_reader :attributes

    class Attribute
      include Equalizer.new(:name, :key, :type)

      attr_reader :name, :key, :meta

      class Embedded < Attribute
        include Equalizer.new(:name, :type, :model, :header)

        def model
          meta.fetch(:model)
        end

        def header
          meta.fetch(:header)
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
        if input.kind_of?(self)
          input
        else
          name = input[0]
          meta = (input[1] || {}).dup

          meta[:type] ||= Object

          if meta.key?(:header)
            meta[:header] = Header.coerce(meta[:header])
          end

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
    end

    def self.coerce(input)
      if input.kind_of?(self)
        input
      else
        attributes = input.each_with_object({}) { |pair, h|
          h[pair.first] = Attribute.coerce(pair)
        }

        new(attributes)
      end
    end

    def initialize(attributes)
      @attributes = attributes
    end

    def each(&block)
      return to_enum unless block
      attributes.values.each(&block)
    end

    def keys
      attributes.keys
    end

    def mapping
      Hash[map { |attribute| [attribute.key, attribute.name] }]
    end

    def values
      attributes.values
    end

    def [](name)
      attributes.fetch(name)
    end

  end

end
