module ROM
  module RA
    class Operation

      class Join
        include Concord::Public.new(:left, :right)
        include Enumerable

        def each(&block)
          return to_enum unless block

          tuples = left.map { |tuple|
            other = right.detect { |t| (tuple.to_a & t.to_a).any? }
            next unless other
            tuple.merge(other)
          }.compact

          tuples.each(&block)
        end

      end

    end
  end
end
