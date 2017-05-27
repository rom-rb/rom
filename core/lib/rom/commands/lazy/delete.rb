module ROM
  module Commands
    class Lazy
      class Delete < Lazy
        def call(*args)
          first = args.first
          last = args.last
          size = args.size

          if size > 1 && last.is_a?(Array)
            raise NotImplementedError
          else
            input = evaluator.call(first)

            if input.is_a?(Array)
              input.map do |item|
                command_proc[command, *(size > 1 ? [last, item] : [input])].call
              end
            else
              command_proc[command, input].call
            end
          end
        end
      end
    end
  end
end
