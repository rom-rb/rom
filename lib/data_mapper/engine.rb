module DataMapper
  class Engine
    attr_reader :adapter
    attr_reader :relations

    # @api private
    def initialize(uri = nil)
      @uri       = uri
      @relations = RelationRegistry.new(self)
    end

    # @api public
    def relation_node_class
      RelationRegistry::RelationNode
    end

    # @api public
    def relation_edge_class
      RelationRegistry::RelationEdge
    end

    # @api public
    def base_relation(name)
      raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
    end

    # @api public
    def gateway_relation(relation)
      relation
    end
  end
end
