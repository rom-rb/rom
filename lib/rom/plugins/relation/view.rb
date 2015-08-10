require 'rom/plugins/relation/view/dsl'

module ROM
  module Plugins
    module Relation
      module View
        def self.included(klass)
          klass.class_eval do
            extend(ClassInterface)

            defines :attributes
            attributes({})
          end
          super
        end

        # Return column names that will be selected for this relation
        #
        # By default we use dataset columns but first we look at configured
        # attributes by `view` DSL
        #
        # @return [Array<Symbol>]
        #
        # @api private
        def attributes(view_name = name)
          self.class.attributes.fetch(view_name, dataset.columns)
        end

        module ClassInterface
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
            name, names, relation_block =
              if block.arity == 0
                DSL.new(*args, &block).call
              else
                [*args, block]
              end

            attributes[name] = names

            define_method(name, &relation_block)
          end
        end
      end
    end
  end

  plugins do
    register :view, Plugins::Relation::View, type: :relation
  end
end
