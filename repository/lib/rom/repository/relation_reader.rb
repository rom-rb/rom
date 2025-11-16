# frozen_string_literal: true

module ROM
  class Repository
    # @api private
    class RelationReader < ::Module
      def self.added_to?(klass)
        klass < InstanceMethods
      end

      module InstanceMethods
        extend ::Dry::Core::Deprecations[:'rom-repository']

        private

        # @api public
        def prepare_relation(name, **)
          container
            .relations[name]
            .with(
              auto_struct: auto_struct,
              struct_namespace: struct_namespace
            )
        end

        # @api private
        deprecate :set_relation, :prepare_relation

        # @api private
        def relation_reader(cache, ...)
          cache_key = relation_cache_key(...)
          cache.fetch_or_store(*cache_key) { prepare_relation(...) }
        end

        # @api private
        def relation_cache_key(name, **kwargs)
          [name, auto_struct, struct_namespace, kwargs]
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
      def initialize(relations:, cache:, root: Undefined)
        super()

        add_readers(relations, cache, root)
      end

      # @api private
      def add_readers(relations, cache, root)
        include cache.fetch_or_store(:relation_readers) {
          Readers.new(relations)
        }

        unless Undefined.equal?(root)
          define_method(:root) { |**kwargs| public_send(root, **kwargs) }
        end
      end
    end
  end
end
