require 'concurrent/map'
require 'rom/setup/finalize/commands'

module ROM
  class Repository
    class CommandCompiler
      def self.[](*args)
        cache.fetch_or_store(args.hash) do
          container, type, adapter, ast = args
          command_opts = new(type, adapter, container, registry).visit(ast)

          ROM::Commands::Graph.build(registry, command_opts)
        end
      end

      def self.cache
        @__cache__ ||= Concurrent::Map.new
      end

      def self.registry
        @__registry__ ||= Hash.new { |h, k| h[k] = {} }
      end

      attr_reader :type, :adapter, :container, :registry

      def initialize(type, adapter, container, registry)
        @type = Commands.const_get(Inflector.classify(type))[adapter]
        @registry = registry
        @container = container
      end

      def visit(ast)
        name, node = ast
        __send__(:"visit_#{name}", node)
      end

      def visit_relation(node)
        name, meta, header = node
        base_name = meta[:base_name]
        other = visit(header)

        mapping =
          if meta[:combine_type] == :many
            base_name
          else
            { Inflector.singularize(name).to_sym => base_name }
          end

        register_command(base_name, type, meta)

        [mapping, [type].concat(other)]
      end

      def visit_header(node)
        node.map { |n| visit(n) }.compact
      end

      def visit_attribute(node)
        nil
      end

      def register_command(name, type, meta)
        klass = ClassBuilder.new(name: "Create[#{name}]", parent: type).call

        if meta[:combine_type]
          klass.use(:associates)
          klass.associates(:parent, key: meta[:keys].invert.to_a.flatten)
          klass.result meta[:combine_type]
        end

        relation = container.relations[name]
        klass.send(:include, finalizer.relation_methods_mod(relation.class))

        registry[name][type] = klass.build(container.relations[name], result: :one)
      end

      # @api private
      def finalizer
        # TODO: we only need `relation_methods_mod` so would be nice to expose it
        #       as a class method instead
        @finalizer ||= Finalize::FinalizeCommands.new(container.relations, nil, nil)
      end
    end
  end
end
