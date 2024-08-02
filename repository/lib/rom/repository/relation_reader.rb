# frozen_string_literal: true

module ROM
  class Repository
    # @api private
    class RelationReader < Module
      extend Dry::Core::ClassAttributes

      # @api private
      attr_reader :klass

      # @api private
      attr_reader :relations

      defines :relation_readers

      defines :mutex
      mutex(Mutex.new)

      defines :relation_cache
      relation_cache(Concurrent::Hash.new)

      module InstanceMethods
        # @api private
        def set_relation(name)
          container
            .relations[name]
            .with(auto_struct: auto_struct, struct_namespace: struct_namespace)
        end

        def relation_reader(name, relation_cache)
          key = [name, auto_struct, struct_namespace]
          relation_cache[key] ||= set_relation(name)
        end
      end

      # @api private
      def mutex
        ROM::Repository::RelationReader.mutex
      end

      # @api private
      def initialize(klass, relations)
        @relations = relations
        mutex.synchronize do
          unless self.class.relation_readers
            self.class.relation_readers(build_relation_readers(relations, self.class.relation_cache))
          end
        end
        klass.include self.class.relation_readers
      end

      # @api private
      def included(klass)
        super
        klass.include(InstanceMethods)
      end


      private

      # @api private
      def build_relation_readers(relations, relation_cache)
        Module.new do
          relations.each do |name|
            define_method(name) do
              relation_reader(name, relation_cache)
            end
          end
        end
      end
    end
  end
end
