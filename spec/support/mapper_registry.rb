module MapperRegistry
  def mapper_for(relation)
    ROM::Repository::MapperBuilder.registry.fetch(relation.to_ast.hash) {
      mapper_builder[relation.to_ast]
    }
  end

  def mapper_builder
    @mapper_builder ||= ROM::Repository::MapperBuilder.new
  end
end
