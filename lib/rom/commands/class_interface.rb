require 'rom/support/class_builder'

module ROM
  # Base command class with factory class-level interface and setup-related logic
  #
  # @private
  class Command
    module ClassInterface
      # Return adapter specific sub-class based on the adapter identifier
      #
      # This is a syntax sugar to make things consistent
      #
      # @example
      #   ROM::Commands::Create[:memory]
      #   # => ROM::Memory::Commands::Create
      #
      # @param [Symbol] adapter identifier
      #
      # @return [Class]
      #
      # @api public
      def [](adapter)
        adapter_namespace(adapter).const_get(Inflector.demodulize(name))
      end

      # Return namespaces that contains command subclasses of a specific adapter
      #
      # @param [Symbol] adapter identifier
      #
      # @return [Module]
      #
      # @api private
      def adapter_namespace(adapter)
        ROM.adapters.fetch(adapter).const_get(:Commands)
      rescue KeyError
        raise AdapterNotPresentError.new(adapter, :relation)
      end

      # Build a command class for a specific relation with options
      #
      # @example
      #   class CreateUser < ROM::Commands::Create[:memory]
      #   end
      #
      #   command = CreateUser.build(rom.relations[:users])
      #
      # @param [Relation] relation
      # @param [Hash] options
      #
      # @return [Command]
      #
      # @api public
      def build(relation, options = EMPTY_HASH)
        new(relation, self.options.merge(options))
      end

      # Create a command class with a specific type
      #
      # @param [Symbol] command name
      # @param [Class] parent class
      #
      # @yield [Class] create class
      #
      # @return [Class, Object] return result of the block if it was provided
      #
      # @api public
      def create_class(name, type, &block)
        klass = ClassBuilder
          .new(name: "#{Inflector.classify(type)}[:#{name}]", parent: type)
          .call

        if block
          yield(klass)
        else
          klass
        end
      end

      # Use a configured plugin in this relation
      #
      # @example
      #   class CreateUser < ROM::Commands::Create[:memory]
      #     use :pagintion
      #
      #     per_page 30
      #   end
      #
      # @param [Symbol] plugin
      # @param [Hash] options
      # @option options [Symbol] :adapter (:default) first adapter to check for plugin
      #
      # @api public
      def use(plugin, _options = EMPTY_HASH)
        ROM.plugin_registry.commands.fetch(plugin, adapter).apply_to(self)
      end

      # Extend a command class with relation view methods
      #
      # @param [Relation]
      #
      # @return [Class]
      #
      # @api public
      def extend_for_relation(relation)
        include(relation_methods_mod(relation.class))
      end

      # Return default name of the command class based on its name
      #
      # During setup phase this is used by defalut as `register_as` option
      #
      # @return [Symbol]
      #
      # @api private
      def default_name
        Inflector.underscore(Inflector.demodulize(name)).to_sym
      end

      # Return default options based on class macros
      #
      # @return [Hash]
      #
      # @api private
      def options
        { input: input, validator: validator, result: result }
      end

      # @api private
      def relation_methods_mod(relation_class)
        Module.new do
          def name
            relation.name.relation
          end

          relation_class.view_methods.each do |meth|
            next if meth == :name

            module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{meth}(*args)
                response = relation.public_send(:#{meth}, *args)

                if response.is_a?(relation.class)
                  new(response)
                else
                  response
                end
              end
            RUBY
          end
        end
      end
    end
  end
end
