module MapperRegistry
  def mapper_for(relation)
    mapper_compiler[relation.to_ast]
  end

  def mapper_compiler
    @mapper_compiler ||= ROM::MapperCompiler.new
  end
end
