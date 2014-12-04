module ROM

  class Result
    attr_reader :value, :error

    def to_ary
      raise NotImplementedError
    end
    alias_method :to_a, :to_ary

    class Success < Result
      def initialize(value)
        @value = value
      end

      def >(f)
        f.call(value)
      end

      def to_ary
        value
      end
      alias_method :to_a, :to_ary
    end

    class Failure < Result
      def initialize(error)
        @error = error
      end

      def >(f)
        self
      end

      def to_ary
        error
      end
    end
  end

  class CommandRegistry < Registry

    class Evaluator
      include Concord.new(:registry)

      private

      def method_missing(name, *args, &block)
        command = registry[name]

        super unless command

        if args.size > 1
          command.new(*args, &block)
        else
          command.execute(*args, &block)
        end
      end
    end

    def try(&f)
      Result::Success.new(Evaluator.new(self).instance_exec(&f))
    rescue CommandError => e
      Result::Failure.new(e)
    end
  end

end
