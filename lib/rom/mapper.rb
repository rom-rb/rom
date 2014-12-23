module ROM
  # @api private
  class Mapper
    attr_reader :header, :model, :loader, :transformer

    class Basic < Mapper
      attr_reader :mapping

      def initialize(*args)
        super
        @mapping = header.mapping
      end

      def load(tuple)
        super(Hash[call(tuple)])
      end

      def call(tuple)
        tuple.map { |key, value| [header.mapping[key], value] }
      end
    end

    class Recursive < Basic
      attr_reader :transformer

      def initialize(*args)
        super
        @transformer = Transformer.build(header)
      end

      def process(relation)
        transformer.call(relation.to_a).each { |tuple| yield(load(tuple)) }
      end

      def call(tuple, header = self.header)
        mapping = header.mapping

        tuple.map do |key, value|
          case value
          when Hash
            attr = header.by_key[key]
            [mapping[key], loader[Hash[call(value, attr)], attr.model]]
          when Array
            loaded = value.map do |val|
              attr = header.by_key[key]
              loader[Hash[call(val, attr)], attr.model]
            end
            [mapping[key], loaded]
          else
            [mapping[key], value]
          end
        end
      end
    end

    def self.build(header, model)
      klass =
        if header.any?(&:embedded?)
          Recursive
        elsif header.any?(&:aliased?)
          Basic
        else
          self
        end

      loader = proc { |tuple, m| m ? m.new(tuple) : tuple }

      klass.new(header, model, loader)
    end

    def initialize(header, model, loader)
      @header = header
      @model = model
      @loader = loader
    end

    def process(relation)
      relation.each { |tuple| yield(load(tuple)) }
    end

    def load(tuple)
      loader[tuple, model]
    end
  end
end
