class TestEnv < DataMapper::Environment

  def initialize(*)
    reset_constants
    super
  end

  def reset!(registry = nil)
    super
    remove_constants!
    clear_mappers!
    reset_engines!
  end

  def remove_constants!
    @constants.each do |name|
      remove_constant(name)
    end
    reset_constants
    self
  end

  def clear_mappers!
    mapper_descendants.each do |klass|
      name = klass.name

      const, parent =
        if name =~ /::/
          [ name.split('::').last, klass.model ]
        else
          [ name, Object ]
        end

      next if const.nil? || const == ''

      if parent.const_defined?(const)
        parent.send(:remove_const, const)
      end
    end

    [ Mapper, Relation::Mapper ].each do |klass|
      klass.instance_variable_set(:@descendants, [])
    end
  end

  def reset_engines!
    engines.each_value do |engine|
      engine.instance_variable_set(:@relations, engine.relations.class.new(engine))
    end
  end

  def mock_model(type)
    if Object.const_defined?(type)
      Object.const_get(type)
    else
      register_constant(type)
      Object.const_set(type, Class.new(OpenStruct))
    end
  end

  def mock_mapper(model_class, attributes = [], relationships = [])
    name = "#{model_class.name}Mapper"

    klass = build(model_class, :test) do
      relation_name Inflector.tableize(model_class.name).to_sym
    end

    attributes.each do |attribute|
      klass.attributes << attribute
    end

    relationships.each do |relationship|
      klass.relationships << relationship
    end

    if Object.const_defined?(name)
      remove_constant(name)
    end

    Object.const_set name, klass

    register_constant(klass.name)

    klass
  end

  private

  def reset_constants
    @constants = Set.new
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

  def mapper_descendants
    [ Mapper.descendants + Relation::Mapper.descendants ].flatten.uniq - [ Relation::Mapper ]
  end

end
