# encoding: utf-8

module ROM

  class Mapping

    class Definition

      def self.build(header, &block)
        new(header).instance_eval(&block).freeze
      end

      def initialize(header)
        @header     = header
        @map        = {}
        @attributes = []
      end

      def header
        @header.project(@attributes.concat(@map.keys))
      end

      def mapping
        @map
      end

      def model(model = Undefined)
        if model == Undefined
          @model
        else
          @model = model
        end
      end

      def map(*args)
        options = args.last

        if options.is_a?(Hash)
          @map.update(args.first => options[:to])
        else
          @attributes.concat(args)
        end

        self
      end
    end

    attr_reader :env, :registry, :model

    # @api public
    def self.build(env, &block)
      new(env, &block).registry
    end

    # @api private
    def initialize(env, &block)
      @env      = env
      @registry = {}
      instance_eval(&block)
    end

    private

    # @api private
    def method_missing(name, *args, &block)
      relation = env[name]

      if relation
        build_relation(relation, &block)
      else
        super
      end
    end

    # @api private
    def build_relation(relation, &block)
      definition = Definition.build(relation.header, &block)
      header     = Mapper::Header.build(definition.header, map: definition.mapping)
      mapper     = Mapper.build(header, definition.model)

      registry[relation.name] = Relation.build(relation, mapper)
    end

  end # Mapping

end # ROM
