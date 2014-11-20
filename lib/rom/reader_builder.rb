module ROM

  # @api private
  class ReaderBuilder
    attr_reader :relations, :readers

    # @api private
    def initialize(relations)
      @relations = relations
      @readers = {}
    end

    # @api private
    def call(name, options = {}, &block)
      parent = relations[options.fetch(:parent) { name }]

      builder = MapperBuilder.new(name, parent, options)
      builder.instance_exec(&block)
      mapper = builder.call

      mappers = options[:parent] ? readers.fetch(parent.name).mappers : {}

      mappers[name] = mapper
      readers[name] = Reader.new(name, parent, mappers) unless options[:parent]
    end

  end
end
