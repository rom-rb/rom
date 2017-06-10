module MapperRegistry
  def mapper_for(relation)
    relation.mapper
  end
end
