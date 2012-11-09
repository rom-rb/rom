module DataMapper
  class Relationship

    class ManyToMany < OneToMany

      def initialize(*)
        super

        @via ||= infer_via
      end

      # @see Options#default_target_key
      #
      # @api private
      def default_source_key
        :id
      end

      # @see Options#default_target_key
      #
      # @api private
      def default_target_key
        self.class.foreign_key_name(target_model.name)
      end

      private

      def infer_via
        Inflector.underscore(target_model.name).to_sym
      end
    end # class ManyToMany
  end # class Relationship
end # module DataMapper
