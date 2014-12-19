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
        tuples.map { |tuple|
          keys = tuple.keys - names
          root = Hash[keys.zip(tuple.values_at(*keys))]
          child = Hash[names.zip(tuple.values_at(*names))]

          root.merge(key => child)
        }
      end
    end

    class Group < Operation
      def call(tuples)
        tuples.
          group_by { |tuple|
            keys = tuple.keys - names
            Hash[keys.zip(tuple.values_at(*keys))]
          }.map { |root, children|
            root.merge(
             key => children.map { |child| Hash[names.zip(child.values_at(*names))] }
            )
          }
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
