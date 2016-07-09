module ROM
  class RelationRegistry < Registry
    def initialize(elements = {}, name = self.class.name)
      super

      yield(self, elements) if block_given?
    end
  end
end
