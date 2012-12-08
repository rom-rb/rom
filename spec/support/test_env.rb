class TestEnv

  def self.instance
    @instance ||= new
  end

  def initialize
    reset!
  end

  def <<(name)
    @constants << name
  end

  def clear!
    remove_constants
    reset_mappers
    reset!
  end

  def remove_constants
    @constants.each do |name|
      remove_constant(name)
    end
    self
  end

  def reset_mappers
    [ Mapper, Relation::Mapper ].each do |klass|
      klass.instance_variable_set(:@descendants, [])
    end
    self
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

    name = "#{model_class.name}Mapper"

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

end
