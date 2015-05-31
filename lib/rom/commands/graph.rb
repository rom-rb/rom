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
      def self.build(registry, options, root = nil)
        options.reduce { |spec, other| build_command(registry, spec, other, root) }
      end

      # @api private
      def self.build_command(registry, spec, other, root = nil)
        name, nodes = other

        key, relation =
          if spec.is_a?(Hash)
            spec.to_a.first
          else
            [spec, spec]
          end

        input_proc = -> input { root ? input.fetch(root).fetch(key) : input.fetch(key) }

        command = registry[relation][name].with(input_proc)

        if nodes
          command.combine(build(registry, nodes, key))
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
          if node.curry_args.first.is_a?(Proc)
            node.call(*args, left)
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
