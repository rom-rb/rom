module ROM
  module Commands

    class Delete
      include Concord.new(:relation, :target)

      def self.build(relation, target = relation)
        new(relation, target)
      end

      def call
        execute
      end

      def execute
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

      def new(*args, &block)
        self.class.new(relation, relation.public_send(*args, &block))
      end

    end

  end
end
