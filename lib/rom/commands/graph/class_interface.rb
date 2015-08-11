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
          name, nodes = other

          key, relation =
            if spec.is_a?(Hash)
              spec.to_a.first
            else
              [spec, spec]
            end

          excluded_keys =
            if nodes
              nodes
                .map { |item| item.is_a?(Array) && item.size > 1 ? item.first : item }
                .compact
                .map { |item| item.is_a?(Hash) ? item.keys.first : item }
            end

          exclude_keys = -> input {
            input.reject { |k, _| excluded_keys.include?(k) }
          }

          command = registry[relation][name]

          tuple_path = Array[*path] << key

          input_proc = -> *args do
            input, index = args

            begin
              value =
                if index
                  tuple_path[0..tuple_path.size-2]
                    .reduce(input) { |a,e| a.fetch(e) }
                    .at(index)[tuple_path.last]
                else
                  tuple_path.reduce(input) { |a,e| a.fetch(e) }
                end

              if excluded_keys
                value.is_a?(Array) ? value.map(&exclude_keys) : exclude_keys[value]
              else
                value
              end
            rescue KeyError => err
              raise CommandFailure.new(command, err)
            end
          end

          command = command.with(input_proc)

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
