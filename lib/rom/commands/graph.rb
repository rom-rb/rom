require 'rom/pipeline'

module ROM
  module Commands
    # Command graph
    #
    # @api private
    class Graph
      include Pipeline
      include Pipeline::Proxy

      # @attr_reader [Command] root The root command
      attr_reader :root

      # @attr_reader [Array<Command>] nodes The child commands
      attr_reader :nodes

      alias_method :left, :root
      alias_method :right, :nodes

      # @api private
      def self.build(registry, options, path = EMPTY_ARRAY)
        options.reduce { |spec, other| build_command(registry, spec, other, path) }
      end

      # @api private
      def self.build_command(registry, spec, other, path)
        name, nodes = other

        key, relation =
          if spec.is_a?(Hash)
            spec.to_a.first
          else
            [spec, spec]
          end

        tuple_path = Array[*path] << key

        evaluator = -> input do
          tuple_path.reduce(input) { |a,e| a.fetch(e) }
        end

        command = registry[relation][name].with(evaluator)

        if nodes
          if command.result.equal?(:many)
            raise(
              ArgumentError,
              'command with :many results cannot be used as a root'
            )
          else
            if nodes.all? { |node| node.is_a?(Array) }
              command.combine(*nodes.map { |node| build(registry, node, tuple_path) })
            else
              command.combine(build(registry, nodes, tuple_path))
            end
          end
        else
          command
        end
      end

      # @api private
      def initialize(root, nodes)
        @root = root
        @nodes = nodes
      end

      # Calls root and all nodes with the result from root
      #
      # Graph results are mappable through `combine` operation in mapper DSL
      #
      # @example
      #   create_user = rom.command(:users).create
      #   create_task = rom.command(:tasks).create
      #
      #   command = create_user
      #     .with(name: 'Jane')
      #     .combine(create_task.with(title: 'Task'))
      #
      #   command.call
      #
      # @return [Array] nested array with command results
      #
      # @api public
      def call(*args)
        left = root.call(*args)

        right = nodes.map do |node|
          if node.lazy?
            node.call(args.first, left)
          else
            node.call(left)
          end
        end

        if result.equal?(:one)
          [[left], right]
        else
          [left, right]
        end
      end
    end
  end
end
