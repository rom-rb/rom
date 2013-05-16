module SpecHelper

  def subclass(name = nil)
    Class.new(described_class) do
      define_singleton_method(:name) { "#{name}" }
      yield if block_given?
    end
  end

  def mock_model(name, &block)
    model = Class.new(OpenStruct)

    model.class_eval <<-RUBY
      def self.name
        #{name.inspect}
      end
    RUBY

    model.instance_eval(&block) if block_given?

    model
  end

  def mock_mapper(model_class, attributes = [], relationships = [])
    name = "#{model_class.name}Mapper"

    klass = DM_ENV.build(model_class, :in_memory) do
      relation_name Inflecto.tableize(model_class.name).to_sym
    end

    attributes.each do |attribute|
      klass.attributes << attribute
    end

    relationships.each do |relationship|
      klass.relationships << relationship
    end

    if Object.const_defined?(name)
      DM_ENV.remove_constant(name)
    end

    Object.const_set(name, klass)

    DM_ENV.register_constant(klass.name)

    klass
  end

  def mock_attribute(name, type, options = {})
    Attribute.build(name, options.merge(:type => type))
  end

  def mock_relation(name, header = [], tuples = Axiom::Relation::Empty::ZERO_TUPLE)
    Axiom::Relation::Base.new(name, header, tuples)
  end

  def mock_relationship(name, attributes = {})
    Relationship::OneToMany.new(name, attributes[:source_model], attributes[:target_model], attributes)
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
    DataMapper::Relation::Header::Attribute.build(*args)
  end

end
