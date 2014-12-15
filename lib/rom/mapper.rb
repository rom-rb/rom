module ROM

  # @api private
  class Mapper
    attr_reader :header, :model, :loader

    class Basic < Mapper
      attr_reader :mapping

      def initialize(*args)
        super
        @mapping = header.mapping
      end

      def load(tuple, mapping = self.mapping)
        loader[Hash[call(tuple, mapping)]]
      end

      def call(tuple, mapping = self.mapping)
        tuple.map { |key, value| [mapping[key], value] }
      end
    end

    class Recursive < Basic
      def call(tuple, mapping = self.mapping)
        tuple.map do |key, value|
          case value
          when Hash  then [key, Hash[call(value, mapping[key])]]
          when Array then [key, value.map { |v| Hash[call(v, mapping[key])] }]
          else
            [mapping[key], value]
          end
        end
      end
    end

    def self.build(header, model)
      klass =
        if header.any? { |attribute| attribute.embedded? }
          Recursive
        elsif header.any? { |attribute| attribute.aliased? }
          Basic
        else
          self
        end

      loader =
        if model
          -> tuple { model.new(tuple) }
        else
          -> tuple { tuple }
        end

      klass.new(header, model, loader)
    end

    def initialize(header, model, loader)
      @header = header
      @model = model
      @loader = loader
    end

    def load(tuple)
      loader[tuple]
    end

  end

end
