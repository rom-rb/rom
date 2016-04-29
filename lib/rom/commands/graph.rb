require 'rom/pipeline'
require 'rom/support/options'
require 'rom/commands/graph/class_interface'

module ROM
  module Commands
    # Command graph
    #
    # @api private
    class Graph
      include Dry::Equalizer(:root, :nodes)

      extend ClassInterface

      include Options
      include Pipeline
      include Pipeline::Proxy

      # @attr_reader [Command] root The root command
      attr_reader :root

      # @attr_reader [Array<Command>] nodes The child commands
      attr_reader :nodes

      # @attr_reader [Symbol] root's relation name
      attr_reader :name

      alias_method :left, :root
      alias_method :right, :nodes

      option :mappers, reader: true, default: proc { MapperRegistry.new }

      # @api private
      def initialize(root, nodes, options = EMPTY_HASH)
        super
        @root = root
        @nodes = nodes
        @name = root.name
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

        right = nodes.map { |node|
          response =
            if node.lazy?
              node.call(args.first, left)
            else
              node.call(left)
            end

          if node.one? && !node.graph?
            [response]
          else
            response
          end
        }

        if one?
          [[left], right]
        else
          [left, right]
        end
      end

      # Return a new graph with updated options
      #
      # @api private
      def with(new_options)
        self.class.new(root, nodes, options.merge(new_options))
      end

      # @api private
      def graph?
        true
      end

      private

      # @api public
      def composite_class
        Command::Composite
      end
    end
  end
end
