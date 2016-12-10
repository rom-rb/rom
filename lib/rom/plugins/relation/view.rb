require 'rom/plugins/relation/view/dsl'

module ROM
  module Plugins
    module Relation
      module View
        def self.included(klass)
          super

          klass.class_eval do
            extend ClassInterface

            option :view, reader: true
            option :attributes

            def self.attributes
              @__attributes__ ||= {}
            end
          end
        end

        # Return column names that will be selected for this relation
        #
        # By default we use dataset columns but first we look at configured
        # attributes by `view` DSL
        #
        # @return [Array<Symbol>]
        #
        # @api private
        def attributes(view_name = view)
          if options.key?(:attributes)
            options[:attributes]
          else
            header = self.class.attributes
              .fetch(view_name, self.class.attributes.fetch(:base))

            if header.is_a?(Proc)
              Array(instance_exec(&header))
            else
              Array(header)
            end
          end
        end

        module ClassInterface
          # @api private
          def finalize(registry, relation)
            super

            attributes = relation.class.attributes.reduce({}) do |h, (a, e)|
              h.update(a => e.is_a?(Proc) ? instance_exec(&e) : e)
            end
            relation.class.attributes.update(attributes).freeze
            relation
          end

          # @api private
          def schema_defined!
            super
            # @!method base
            #   Return the base relation with default attributes
            #   @return [Relation]
            #   @api public
            view(:base, schema.attributes.keys) do
              self
            end
          end

          # Define a relation view with a specific header
          #
          # With headers defined all the mappers will be inferred automatically
          #
          # @example
          #   class Users < ROM::Relation[:sql]
          #     view(:by_name, [:id, :name]) do |name|
          #       where(name: name)
          #     end
          #
          #     view(:listing, [:id, :name, :email]) do
          #       select(:id, :name, :email).order(:name)
          #     end
          #   end
          #
          # @api public
          def view(*args, &block)
            if args.size == 1 && block.arity > 0
              raise ArgumentError, "header must be set as second argument"
            end

            name, header, relation_block, new_schema_fn =
              if args.size == 1
                DSL.new(*args, schema, &block).call
              else
                [*args, block]
              end

            attributes[name] = header || new_schema_fn

            if relation_block.arity > 0
              auto_curry_guard do
                define_method(name, &relation_block)

                if new_schema_fn
                  auto_curry(name) do
                    self.class.attributes[name].(self).with(view: name) 
                  end
                else
                  auto_curry(name) do
                    with(view: name) 
                  end
                end
              end
            else
              if new_schema_fn
                define_method(name) do
                  relation = instance_exec(&relation_block)
                  self.class.attributes[name].(relation).with(view: name)
                end
              else
                define_method(name) do
                  relation = instance_exec(&relation_block)
                  relation.with(view: name)
                end
              end
            end
          end
        end
      end
    end
  end
end

ROM.plugins do
  register :view, ROM::Plugins::Relation::View, type: :relation
end
