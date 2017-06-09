require 'rom/registry'

module ROM
  class RelationRegistry < Registry
    def initialize(elements = {})
      super
      yield(self, elements) if block_given?
    end

    def map(&block)
      self.class.new do |r, h|
        elements.each do |name, relation|
          h[name] = yield(relation)
        end
      end
    end
  end
end
