# frozen_string_literal: true

require "rom/commands/graph/input_evaluator"

module ROM
  module Commands
    class Graph
      # Class methods for command Graph
      #
      # @api private
      module ClassInterface
        # Build a command graph recursively
        #
        # This is used by `Container#command` when array with options is passed in
        #
        # @param [Registry] registry The command registry from container
        # @param [Array] options The options array
        # @param [Array] path The path for input evaluator proc
        #
        # @return [Graph]
        #
        # @api private
        def build(registry, options, path = EMPTY_ARRAY)
          options.reduce { |spec, other| build_command(registry, spec, other, path) }
        end

        # @api private
        def build_command(registry, spec, other, path)
          cmd_opts, nodes = other

          key, relation =
            if spec.is_a?(Hash)
              spec.to_a.first
            else
              [spec, spec]
            end

          name, opts =
            if cmd_opts.is_a?(Hash)
              cmd_opts.to_a.first
            else
              [cmd_opts]
            end

          command = registry[relation][name]
          tuple_path = Array[*path] << key
          input_proc = InputEvaluator.build(tuple_path, nodes)

          command = command.curry(input_proc, opts)

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
      end
    end
  end
end
