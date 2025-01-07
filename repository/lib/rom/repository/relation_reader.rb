# frozen_string_literal: true

module ROM
  class Repository
    # @api private
    class RelationReader < ::Module
      module InstanceMethods
        private

        # @api private
        def prepare_relation(name, **)
          container
            .relations[name]
            .with(
              auto_struct: auto_struct,
              struct_namespace: struct_namespace
            )
        end

        # @api private
        def relation_reader(cache, ...)
          cache_key = relation_cache_key(...)
          cache.fetch_or_store(*cache_key) { prepare_relation(...) }
        end

        # @api private
        def relation_cache_key(name, **)
          [name, auto_struct, struct_namespace]
        end
      end

      # @api private
      class Readers < ::Module
        # @api private
        attr_reader :cache

        def initialize(relations)
          super()

          include InstanceMethods

          define_readers(relations)
        end

        # @api private
        def define_readers(relations)
          cache = Cache.new
          relations.each do |name|
            define_readers_for_relation(cache, name)
          end
        end

        # @api private
        def define_readers_for_relation(cache, name)
          define_method(name) do |**kwargs|
            relation_reader(cache, name, **kwargs)
          end
        end
      end

      # @api private
      def initialize(relations:, cache:)
        super()

        add_readers(relations, cache)
      end

      # @api private
      def add_readers(relations, cache)
        include cache.fetch_or_store(:relation_readers) {
          Readers.new(relations)
        }
      end
    end
  end
end
