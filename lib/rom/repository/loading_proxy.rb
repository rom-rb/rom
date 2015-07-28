require 'charlatan'

module ROM
  class Repository
    attr_reader :mapper_builder

    class LoadingProxy
      include Charlatan.new(:relation)

      attr_reader :mapper

      def initialize(relation, mapper_builder)
        super
        @mapper = mapper_builder[relation]
      end

      def to_a
        (relation.to_lazy >> mapper).to_a
      end
    end
  end
end
