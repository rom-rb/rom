require 'rom/boot/dsl'

module ROM

  class Boot
    attr_reader :repositories

    def initialize(repositories)
      @repositories = repositories
      @schema = {}
      @relations = []
      @mappers = []
    end

    def schema(&block)
      @schema = DSL.new(self).schema(&block)
    end

    def finalize
      relations =
        if @schema.any?
          relations = @schema.each_with_object({}) do |(name, args), h|
            h[name] = Relation.new(*args)
          end
        else
          load_schema.each_with_object({}) do |(name, dataset, header, ext), h|
            relation = Relation.new(dataset, header)
            relation.extend(ext) if ext

            h[name] = relation
          end
        end

      Env.new(repositories, Schema.new(relations))
    end

    def [](name)
      repositories[name]
    end

    def respond_to_missing?(name, include_private = false)
      repositories.key?(name)
    end

    private

    def method_missing(name, *args)
      repositories.fetch(name)
    end

    def load_schema
      repositories.values.map { |repo| repo.schema }.reduce(:+)
    end

  end

end
