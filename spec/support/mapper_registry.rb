module MapperRegistry
  def mapper_for(relation)
    mapper_builder[relation.to_ast]
  end

  def mapper_builder
    @mapper_builder ||= ROM::Repository::MapperBuilder.new
  end
end
