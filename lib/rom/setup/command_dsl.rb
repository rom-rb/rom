module ROM
  class Setup
    class CommandDSL
      attr_reader :commands

      class CommandDefinition
        include Options

        option :type, type: Symbol, reader: true, allow: [:create, :update, :delete]

        alias_method :to_h, :options

        def initialize(options, &block)
          super
          instance_exec(&block) if block
        end

        private

        def method_missing(name, *args, &block)
          if args.size == 1
            options[name] = args.first
          else
            super
          end
        end
      end

      def initialize(&block)
        @commands = {}
        instance_exec(&block)
      end

      def define(name, options = {}, &block)
        commands[name] = CommandDefinition.new(options, &block)
        self
      end
    end
  end
end
