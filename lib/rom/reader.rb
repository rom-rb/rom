module ROM

  class Reader
    include Enumerable
    include Equalizer.new(:path, :relation, :mapper)

    attr_reader :path, :relation, :header, :mappers, :mapper

    def initialize(path, relation, mappers = {})
      @path = path.to_s
      @relation = relation
      @header = relation.header
      @mappers = mappers

      names = @path.split('.')

      mapper_key = names.reverse.detect { |name| mappers.key?(name.to_sym) }
      @mapper = mappers.fetch(mapper_key.to_sym)
    end

    def each
      relation.each { |tuple| yield(mapper.load(tuple)) }
    end

    def respond_to_missing?(name, include_private = false)
      relation.respond_to?(name)
    end

    private

    def method_missing(name, *args, &block)
      new_relation = relation.public_send(name, *args, &block)

      splits = path.split('.')
      splits << name
      new_path = splits.join('.')

      self.class.new(new_path, new_relation, mappers)
    end

  end

end
