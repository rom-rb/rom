module ROM
  module RA
    class Operation

      class Join
        include Concord::Public.new(:left, :right)
        include Enumerable

        def header
          left.header + right.header
        end

        def each(&block)
          return to_enum unless block

          tuples = right.map { |tuple|
            other = left.detect { |t| (tuple.to_a & t.to_a).any?  }
            next unless other
            tuple.merge(other)
          }.compact

          tuples.each(&block)
        end

      end

    end
  end
end
