class TestEnv < Rom::Environment

  def initialize(config)
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
