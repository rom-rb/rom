class TestEnv

  def self.instance
    @instance ||= new
  end

  def initialize
    reset!
  end

  def <<(name)
    @constants << name.to_sym
  end

  def clear!
    remove_constants!
    clear_mappers!
    reset!
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

    reset_mappers!
    reset_engines!
  end

  def remove_constants!
    @constants.each do |name|
      remove_constant(name)
    end
    self
  end

  def reset_mappers!
    [ Mapper, Relation::Mapper ].each do |klass|
      klass.instance_variable_set(:@descendants, [])
    end
    self
  end

  def reset_engines!
    DM_ENV.engines.each_value do |engine|
      engine.instance_variable_set(:@relations, engine.relations.class.new(engine))
    end

    DataMapper::Relation::Mapper.instance_variable_set(:@relations, nil)
    DataMapper::Mapper.instance_variable_set(:@registry, nil)

    DM_ENV.instance_variable_set(:@finalized, false)
  end

  def mock_model(type)
    if Object.const_defined?(type)
      Object.const_get(type)
    else
      self << type
      Object.const_set(type, Class.new(OpenStruct))
    end
  end

  def mock_mapper(model_class, attributes = [], relationships = [])
    name = "#{model_class.name}Mapper"

    klass = Class.new(DataMapper::Relation::Mapper) do
      model         model_class
      repository    :test
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

    self << klass.name

    klass
  end

  private

  def reset!
    @constants = Set.new
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
