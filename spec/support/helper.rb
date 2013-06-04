module SpecHelper

  def subclass(name = nil)
    Class.new(described_class) do
      define_singleton_method(:name) { "#{name}" }
      yield if block_given?
    end
  end

  def mock_relation(name, header = [], tuples = Axiom::Relation::Empty::ZERO_TUPLE)
    Axiom::Relation::Base.new(name, header, tuples)
  end

  def mock_connector(attributes)
    OpenStruct.new(attributes)
  end

  def mock_node(name)
    OpenStruct.new(:name => name)
  end

  def mock_join_definition(left_relation, right_relation, left_keys, right_keys)
    left  = Relationship::JoinDefinition::Side.new(left_relation,  left_keys)
    right = Relationship::JoinDefinition::Side.new(right_relation, right_keys)
    Relationship::JoinDefinition.new(left, right)
  end

  def attribute_alias(*args)
    ROM::Relation::Header::Attribute.build(*args)
  end

end
