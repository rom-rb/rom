module DataMapper
  class Engine
    attr_reader :adapter
    attr_reader :relations

    # @api private
    # TODO: add specs
    def initialize(uri = nil)
      @uri       = uri
      @relations = RelationRegistry.new(self)
    end

    # @api public
    # TODO: add specs
    def relation_node_class
      RelationRegistry::RelationNode
    end

    # @api public
    # TODO: add specs
    def relation_edge_class
      RelationRegistry::RelationEdge
    end

    # @api public
    # TODO: add specs
    def base_relation(name)
      raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
    end

    # @api public
    # TODO: add specs
    def gateway_relation(relation)
      relation
    end
  end
end
