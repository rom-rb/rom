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
        def foreign_key(other = nil)
          if other
            if schema
              base_name = other.is_a?(Symbol) ? other : other.base_name
              schema.foreign_key(base_name).meta[:name]
            else
              relation = other.is_a?(Symbol) ? __registry__[other] : other
              relation.foreign_key
            end
          else
            :"#{Inflector.singularize(name)}_id"
          end
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
end

ROM.plugins do
  register :key_inference, ROM::Plugins::Relation::KeyInference, type: :relation
end
