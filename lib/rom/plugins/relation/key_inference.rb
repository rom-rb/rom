module ROM
  module Plugins
    module Relation
      module KeyInference
        # Infer foreign_key name for this relation
        #
        # TODO: this should be configurable and handled by an injected policy
        #
        # @return [Symbol]
        #
        # @api private
        def foreign_key
          :"#{Inflector.singularize(name)}_id"
        end

        # Return base name which defaults to name attribute
        #
        # @return [Symbol]
        #
        # @api private
        def base_name
          name
        end
      end
    end
  end

  plugins do
    register :key_inference, Plugins::Relation::KeyInference, type: :relation
  end
end
