require 'dry/core/class_builder'

module ROM
  # Base command class with factory class-level interface and setup-related logic
  #
  # @private
  class Command
    module ClassInterface
      # This hook sets up default class state
      #
      # @api private
      def inherited(klass)
        super
        klass.instance_variable_set(:'@before', before.dup)
        klass.instance_variable_set(:'@after', after.dup)
      end

      # Sets up the base class
      #
      # @api private
      def self.extended(klass)
        super
        klass.set_hooks(:before, [])
        klass.set_hooks(:after, [])
      end

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
        adapter_namespace(adapter).const_get(ROM.inflector.demodulize(name))
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
      # @param [Symbol] name Command name
      # @param [Class] type Command class
      #
      # @yield [Class]
      #
      # @return [Class, Object]
      #
      # @api public
      def create_class(name, type, &block)
        klass = Dry::Core::ClassBuilder
          .new(name: "#{ROM.inflector.classify(type)}[:#{name}]", parent: type)
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
      # @param [Hash] _options
      # @option _options [Symbol] :adapter (:default) first adapter to check for plugin
      #
      # @api public
      def use(plugin, options = EMPTY_HASH)
        ROM.plugin_registry.commands.fetch(plugin, adapter).apply_to(self, options)
      end

      # Extend a command class with relation view methods
      #
      # @param [Relation] relation
      #
      # @return [Class]
      #
      # @api public
      def extend_for_relation(relation)
        include(relation_methods_mod(relation.class))
      end

      # Set before-execute hooks
      #
      # @overload before(hook)
      #   Set an before hook as a method name
      #
      #   @example
      #     class CreateUser < ROM::Commands::Create[:sql]
      #       relation :users
      #       register_as :create
      #
      #       before :my_hook
      #
      #       def my_hook(tuple, *)
      #         puts "hook called#
      #       end
      #     end
      #
      # @overload before(hook_opts)
      #   Set an before hook as a method name with arguments
      #
      #   @example
      #     class CreateUser < ROM::Commands::Create[:sql]
      #       relation :users
      #       register_as :create
      #
      #       before my_hook: { arg1: 1, arg1: 2 }
      #
      #       def my_hook(tuple, arg1:, arg2:)
      #         puts "hook called with args: #{arg1} and #{arg2}"
      #       end
      #     end
      #
      #   @param [Hash<Symbol=>Hash>] hook Options with method name and pre-set args
      #
      # @return [Array<Hash, Symbol>] A list of all configured before hooks
      #
      # @api public
      def before(*hooks)
        if hooks.size > 0
          set_hooks(:before, hooks)
        else
          @before
        end
      end

      # Set after-execute hooks
      #
      # @overload after(hook)
      #   Set an after hook as a method name
      #
      #   @example
      #     class CreateUser < ROM::Commands::Create[:sql]
      #       relation :users
      #       register_as :create
      #
      #       after :my_hook
      #
      #       def my_hook(tuple, *)
      #         puts "hook called#
      #       end
      #     end
      #
      # @overload after(hook_opts)
      #   Set an after hook as a method name with arguments
      #
      #   @example
      #     class CreateUser < ROM::Commands::Create[:sql]
      #       relation :users
      #       register_as :create
      #
      #       after my_hook: { arg1: 1, arg1: 2 }
      #
      #       def my_hook(tuple, arg1:, arg2:)
      #         puts "hook called with args: #{arg1} and #{arg2}"
      #       end
      #     end
      #
      #   @param [Hash<Symbol=>Hash>] hook Options with method name and pre-set args
      #
      # @return [Array<Hash, Symbol>] A list of all configured after hooks
      #
      # @api public
      def after(*hooks)
        if hooks.size > 0
          set_hooks(:after, hooks)
        else
          @after
        end
      end

      # Set new or more hooks
      #
      # @api private
      def set_hooks(type, hooks)
        ivar = :"@#{type}"

        if instance_variable_defined?(ivar)
          instance_variable_get(ivar).concat(hooks)
        else
          instance_variable_set(ivar, hooks)
        end
      end

      # Return default name of the command class based on its name
      #
      # During setup phase this is used by defalut as `register_as` option
      #
      # @return [Symbol]
      #
      # @api private
      def default_name
        ROM.inflector.underscore(ROM.inflector.demodulize(name)).to_sym
      end

      # Return default options based on class macros
      #
      # @return [Hash]
      #
      # @api private
      def options
        { input: input, result: result, before: before, after: after }
      end

      # @api private
      def relation_methods_mod(relation_class)
        Module.new do
          relation_class.view_methods.each do |meth|
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
