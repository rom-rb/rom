module ROM

  class Header
    include Equalizer.new(:attributes)

    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes
    end

    def [](name)
      attributes.fetch(name)
    end
  end

end
