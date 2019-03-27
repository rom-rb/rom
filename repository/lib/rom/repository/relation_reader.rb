# frozen_string_literal: true

module ROM
  class Repository
    # @api private
    class RelationReader < Module
      # @api private
      attr_reader :klass

      # @api private
      attr_reader :relations

      module InstanceMethods
        # @api private
        def set_relation(name)
          container.
            relations[name].
            with(auto_struct: auto_struct).
            struct_namespace(struct_namespace)
        end
      end

      # @api private
      def initialize(klass, relations)
        @klass = klass
        @relations = relations
        define_readers!
      end

      # @api private
      def included(klass)
        super
        klass.include(InstanceMethods)
      end

      private

      # @api private
      def define_readers!
        relations.each do |name|
          define_method(name) do
            @relations[name] ||= set_relation(name)
          end
        end
      end
    end
  end
end
