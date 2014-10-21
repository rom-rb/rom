require 'rom/ra/operation/join'

module ROM

  class Schema

    class DSL
      attr_reader :env, :relations

      class Relation
        attr_reader :relations, :name

        def initialize(relations, name)
          @relations = relations
          @name = name
        end

        def call(&block)
          instance_exec(&block)
          relations[name]
        end

        def join(left, right)
          relations[name] = RA::Operation::Join.new(left, right)
        end

        private

        def method_missing(name, *args)
          relations[name] || super
        end
      end

      class BaseRelation
        attr_reader :env, :name, :repositories, :attributes, :datasets

        def initialize(env, name)
          @env = env
          @name = name
          @attributes = {}
        end

        def repository(name)
          @datasets = env[name]
        end

        def attribute(name, type, options = {})
          attributes[name] = { type: type }.merge(options)
        end

        def call(&block)
          instance_exec(&block)
          ROM::Relation.new(datasets[name], Header.new(attributes))
        end
      end

      def initialize(env)
        @env = env
        @relations = {}
      end

      def base_relation(name, &block)
        relations[name] = BaseRelation.new(env, name).call(&block)
      end

      def relation(name, &block)
        relations[name] = Relation.new(relations, name).call(&block)
      end

      def call
        Schema.new(relations)
      end

    end

    include Concord::Public.new(:relations)

    def self.define(env, &block)
      dsl = DSL.new(env)
      dsl.instance_exec(&block)
      dsl.call
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
