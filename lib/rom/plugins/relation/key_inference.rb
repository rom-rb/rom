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
              dataset, relation = case other
                                  when Symbol then [other, other]
                                  when ROM::Relation::Name then [other.dataset, other.relation]
                                  else [other.base_name.dataset, other.base_name.relation]
                                  end

              key = schema.foreign_key(dataset)
              key ? key.meta[:name] : __registry__.fetch(relation).foreign_key
            else
              relation = case other
                         when Symbol then __registry__.fetch(other)
                         when ROM::Relation::Name then __registry__.fetch(other.relation)
                         else other
                         end

              relation.foreign_key
            end
          else
            :"#{Inflector.singularize(name.dataset)}_id"
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
