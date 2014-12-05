module ROM
  module Commands

    class Update
      include Concord.new(:relation, :input, :validator)

      def self.build(relation, definition)
        new(relation, definition.input, definition.validator)
      end

      def execute(params)
        raise NotImplementedError, "#{self.class}#execute must be implemented"
      end

      def new(*args, &block)
        self.class.new(relation.public_send(*args, &block), input, validator)
      end
    end

  end
end
