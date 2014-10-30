require 'rom/ra/operation/join'

module ROM

  class Schema

    class DSL
      attr_reader :env, :relations

      class BaseRelation
        attr_reader :env, :name, :repositories, :attributes, :datasets

        def initialize(env, name)
          @env = env
          @name = name
          @attributes = []
        end

        def repository(name = nil)
          if @repository
            @repository
          else
            @repository = env[name]
          end
        end

        def attribute(name)
          attributes << name
        end

        def call(&block)
          instance_exec(&block)

          dataset = repository[name]

          header =
            if attributes.any?
              attributes
            else
              dataset.header
            end

          ROM::Relation.new(repository[name], header)
        end
      end

      def initialize(env)
        @env = env
        @relations = {}
      end

      def base_relation(name, &block)
        relations[name] = BaseRelation.new(env, name).call(&block)
      end

      def call
        Schema.new(relations)
      end

    end

    include Concord::Public.new(:relations)

    def self.define(env, &block)
      if block
        dsl = DSL.new(env)
        dsl.instance_exec(&block)
        dsl.call
      else
        load_schema(env)
      end
    end

    def self.load_schema(env)
      relations = env.load_schema.each_with_object({}) do |(table, dataset, attributes), hash|
        hash[table] = ROM::Relation.new(dataset, attributes)
      end

      Schema.new(relations)
    end

    def key?(name)
      relations.key?(name)
    end

    def [](name)
      relations.fetch(name)
    end

    def respond_to_missing?(name, include_private = false)
      relations.key?(name)
    end

    def method_missing(name)
      relations.fetch(name)
    end

  end

end
