require 'rom/schema'

module ROM
  module Memory
    class Schema < ROM::Schema
      # @see Schema#call
      # @api public
      def call(relation)
        relation.new(relation.dataset.project(*map(&:name)), schema: self)
      end
    end
  end
end
