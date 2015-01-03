module ROM
  module Commands
    # Common behavior for Create and Update commands
    #
    # TODO: find a better name for this module
    module WithOptions
      def self.included(klass)
        klass.class_eval do
          option :validator, reader: true
          option :input, reader: true
        end
      end

      # @api private
      def initialize(_relation, _options)
        super
        @validator ||= proc {}
        @input ||= Hash
      end
    end
  end
end
