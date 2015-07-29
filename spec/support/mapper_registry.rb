module MapperRegistry
  def mapper_for(relation)
    ROM::Repository::MapperBuilder.registry.fetch(relation.to_ast.hash)
  end
end
