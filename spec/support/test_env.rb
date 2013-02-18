class TestEnv < DataMapper::Environment

  def initialize
    reset_constants
    super
  end

  def reset
    @mappers   = []
    @registry  = Mapper::Registry.new
    @relations = Relation::Graph.new
    @finalized = false

    remove_constants
    clear_mappers
    clear_models
  end

  def remove_constants
    @constants.each do |name|
      remove_constant(name)
    end
    reset_constants
    self
  end

  def clear_mappers
    mapper_classes.each do |klass|
      name = klass.name

      const, parent =
        if name =~ /::/
          [ name.split('::').last, klass.model ]
        else
          [ name, Object ]
        end

      next if const.nil? || const == ''

      if parent.const_defined?(const)
        parent.send(:remove_const, const) rescue nil
      end
    end

    [ Mapper, Relation::Mapper ].each do |klass|
      klass.instance_variable_set(:@descendants, [])
    end
  end

  def clear_models
    model_classes.each do |model|
      next if model.name.nil? || model.name == ''
      remove_constant(model.name) if model.name && Object.const_defined?(model.name)
    end
    Model.instance_variable_set(:"@descendants", [])
  end

  def register_constant(name)
    @constants << name.to_sym
  end

  def remove_constant(name)
    if Object.const_defined?(name)
      Object.send(:remove_const, name)
    else
      raise "[TestEnv] trying to remove non-existant constant: #{name.inspect}"
    end
  end

  def draw(file_name = 'graph.png')
    require 'graphviz'

    # Create a new graph
    g = GraphViz.new( :G, :type => :digraph )

    map = {}

    relations.nodes.each do |relation_node|
      node = g.add_nodes(relation_node.name.to_s)
      map[relation_node] = node
    end

    relations.edges.each do |edge|
      source = map[edge.source_node]
      target = map[edge.target_node]

      g.add_edges(source, target, :label => edge.name.to_s)
    end

    relations.connectors.each do |name, connector|
      source = map[connector.source_node]
      target = map[connector.node]

      relationship = connector.relationship

      label = "#{relationship.source_model.name}##{relationship.name} [#{name}]"

      g.add_edges(source, target, :label => label, :style => 'bold', :color => 'blue')
    end

    # Generate output image
    g.output( :png => file_name )
  end

  private

  def reset_constants
    @constants = Set.new
  end

  def model_classes
    mappers.map(&:model) + Model.descendants
  end

  def mapper_classes
    [ Mapper.descendants + Relation::Mapper.descendants ].flatten.uniq - [ Relation::Mapper ]
  end

end
