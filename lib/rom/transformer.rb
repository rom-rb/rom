module ROM
  class Transformer
    attr_reader :operations

    class Operation
      attr_reader :attribute, :key, :names

      def initialize(attribute)
        @attribute = attribute
        @key = attribute.key
        @names = attribute.header.map(&:key)
      end
    end

    class Wrap < Operation
      def call(tuples)
        keys = nil

        tuples.map { |tuple|
          keys ||= tuple.keys - names

          root = Hash[keys.zip(tuple.values_at(*keys))]
          child = Hash[names.zip(tuple.values_at(*names))]

          root.merge(key => child.values.any? ? child : nil)
        }
      end
    end

    class Group < Operation
      def call(tuples)
        keys = nil

        tuples
          .group_by { |tuple|
            keys ||= tuple.keys - names
            Hash[keys.zip(tuple.values_at(*keys))]
          }.map { |root, children|
            children.map! { |child| Hash[names.zip(child.values_at(*names))] }
            children.select! { |child| child.values.any? }
            root.merge(key => children)
          }
      end
    end

    def self.build(header)
      operations = header.select(&:transform?).map do |attribute|
        type = attribute.type

        if type == Hash
          Wrap.new(attribute)
        elsif type == Array
          Group.new(attribute)
        end
      end.compact

      sorted_ops =
        operations.select { |op| op.is_a?(Group) } +
        operations.select { |op| op.is_a?(Wrap) }

      new(sorted_ops.flatten)
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
