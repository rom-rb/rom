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

      # Build a command graph recursively
      #
      # This is used by `Env#command` when array with options is passed in
      #
      # @param [Registry] registry The command registry from env
      # @param [Array] options The options array
      # @param [Array] path The path for input evaluator proc
      #
      # @return [Graph]
      #
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

        input_proc = -> *args do
          input, index = args

          if index
            tuple_path[0..tuple_path.size-2]
              .reduce(input) { |a,e| a.fetch(e) }
              .at(index)[tuple_path.last]
          else
            tuple_path.reduce(input) { |a,e| a.fetch(e) }
          end
        end

        command = registry[relation][name].with(input_proc)

        if nodes
          if nodes.all? { |node| node.is_a?(Array) }
            command.combine(*nodes.map { |node| build(registry, node, tuple_path) })
          else
            command.combine(build(registry, nodes, tuple_path))
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
