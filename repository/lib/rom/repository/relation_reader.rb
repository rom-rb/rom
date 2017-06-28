module ROM
  class Repository
    # @api private
    class RelationReader < Module
      # @api private
      attr_reader :klass

      # @api private
      attr_reader :relations

      # @api private
      def initialize(klass, relations)
        @klass = klass
        @relations = relations
        define_readers!
      end

      private

      # @api private
      def define_readers!
        relations.each do |name|
          define_method(name) do
            @relations[name] ||= container.
                                   relations[name].
                                   with(auto_struct: auto_struct).
                                   struct_namespace(struct_namespace)
          end
        end
      end
    end
  end
end
