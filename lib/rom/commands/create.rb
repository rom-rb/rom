require 'rom/commands/with_options'

module ROM
  module Commands

    class Create
      include WithOptions

      def execute(tuple)
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

    end

  end
end
