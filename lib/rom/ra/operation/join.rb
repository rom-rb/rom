module ROM
  module RA
    class Operation
      class Join
        include Charlatan.new(:left)
        include Enumerable

        attr_reader :right

        def initialize(left, right)
          super
          @left, @right = left, right
        end

        def header
          left.header + right.header
        end

        def each(&block)
          return to_enum unless block

          join_map = left.each_with_object({}) { |tuple, h|
            others = right.find_all { |t| (tuple.to_a & t.to_a).any? }
            (h[tuple] ||= []).concat(others)
          }

          tuples = left.map { |tuple|
            join_map[tuple].map { |other| tuple.merge(other) }
          }.flatten

          tuples.each(&block)
        end
      end
    end
  end
end
