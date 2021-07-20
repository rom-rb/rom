# frozen_string_literal: true

module MapperRegistry
  def mapper_for(relation)
    relation.mapper
  end
end
