class TestEnv < ROM::Environment

  def initialize(config)
    reset_constants
    super
  end

  def reset
    @relations = Relation::Graph.new
    @finalized = false

    remove_constants
  end

  def remove_constants
    @constants.each do |name|
      remove_constant(name)
    end
    reset_constants
    self
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

end
