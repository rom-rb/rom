require 'rom/registry'

module ROM
  class RelationRegistry < Registry
    def initialize(elements = {})
      super
      yield(self, elements) if block_given?
    end
  end
end
