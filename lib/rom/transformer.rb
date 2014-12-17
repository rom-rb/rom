module ROM

  class Transformer
    attr_reader :operations

    class Wrap
      attr_reader :attribute

      def initialize(attribute)
        @attribute = attribute
      end

      def call(tuples)
        tuples.map do |tuple|
          result = tuple.reject { |k,_| names.include?(k) }
          result[key] = tuple.reject { |k,_| !names.include?(k) }
          result
        end
      end

      def key
        attribute.key
      end

      def names
        attribute.header.map(&:key)
      end
    end

    class Group
      attr_reader :attribute

      def initialize(attribute)
        @attribute = attribute
      end

      def call(tuples)
        result = tuples.each_with_object({}) do |tuple, grouped|
          left = tuple.reject { |k,_| names.include?(k) }
          right = tuple.reject { |k,_| !names.include?(k) }

          grouped[left] ||= {}
          grouped[left][key] ||= []
          grouped[left][key] << right if right.values.any?
        end

        result.map { |k,v| k.merge(v) }
      end

      def key
        attribute.key
      end

      def names
        attribute.header.map(&:key)
      end
    end

    def self.build(header)
      operations = header.map do |attribute|
        type = attribute.type

        if type == Hash
          Wrap.new(attribute)
        elsif type == Array
          Group.new(attribute)
        end
      end

      new(operations.compact)
    end

    def initialize(operations)
      @operations = operations
    end

    def call(input)
      output = input
      operations.each { |op| output = op.call(output) }
      output
    end

  end

end
