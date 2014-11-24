module ROM

  # @api private
  class Mapper
    attr_reader :header, :model

    class Basic < Mapper
      attr_reader :mapping

      def initialize(header, model)
        super
        @mapping = header.mapping
      end

      def load(tuple, mapping = self.mapping)
        model.new(Hash[call(tuple, mapping)])
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

      klass.new(header, model)
    end

    def initialize(header, model)
      @header = header
      @model = model
    end

    def load(tuple)
      model.new(tuple)
    end

  end

end
