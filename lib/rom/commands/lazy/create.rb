module ROM
  module Commands
    class Lazy
      class Create < Lazy
        def call(*args)
          first = args.first
          last = args.last
          size = args.size

          if size > 1 && last.is_a?(Array)
            last.map.with_index do |parent, index|
              children = evaluator.call(first, index)
              command_proc[command, parent, children].call(children, parent)
            end.reduce(:concat)
          else
            input = evaluator.call(first)
            command.call(input, *args[1..size-1])
          end
        end
      end
    end
  end
end
