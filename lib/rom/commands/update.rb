require 'rom/commands/with_options'

module ROM
  module Commands

    class Update
      include WithOptions

      def call(params)
        tuples = execute(params)

        if result == :one
          tuples.first
        else
          tuples
        end
      end
      alias_method :set, :call

      def execute(params)
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

      def new(*args, &block)
        self.class.new(relation.public_send(*args, &block), options)
      end
    end

  end
end
