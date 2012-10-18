module DataMapper
  class Engine
    attr_reader :adapter

    def initialize(uri)
      @uri = uri
    end

    # @api private
    def base_relation(name, header)
      raise NotImplementedError, "#{self.class}#base_relation must be implemented"
    end

    # @api private
    def gateway_relation(relation)
      raise NotImplementedError, "#{self.class}#gateway_relation must be implemented"
    end
  end
end
