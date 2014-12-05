module ROM
  module Commands

    class Update
      include Concord.new(:relation, :input, :validator)

      def self.build(relation, definition)
        new(relation, definition.input, definition.validator)
      end

      def call(params)
        execute(params)
      end
      alias_method :set, :call

      def execute(params)
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

      def new(*args, &block)
        self.class.new(relation.public_send(*args, &block), input, validator)
      end
    end

  end
end
