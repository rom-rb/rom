require 'dry/core/inflector'

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
            if schema?
              rel_name = other.respond_to?(:to_sym) ?
                ROM::Relation::Name[other.to_sym] : other.base_name

              key = schema.foreign_key(rel_name.dataset)
              key ? key.meta[:name] : __registry__[rel_name].foreign_key
            else
              relation = other.respond_to?(:to_sym) ?
                __registry__[other] : other

              relation.foreign_key
            end
          else
            :"#{Dry::Core::Inflector.singularize(name.dataset)}_id"
          end
        end

        # Return base name which defaults to name attribute
        #
        # @return [ROM::Relation::Name]
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
