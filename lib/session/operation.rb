module Session
  # Base class for an operation
  class Operation
    attr_reader :registry,:object

    def initialize(registry,object)
      @registry,@object = registry,object
    end

    def run
      raise NotImplementedError
    end

    def mapper
      registry.resolve_object(object)
    end

    def self.run(*args)
      instance = self.new(*args)
      unless instance.noop?
        instance.run
      end

      self
    end

    # Update operation
    class Update < Operation
      attr_reader :old_dump

      def initialize(registry,object,old_dump)
        super(registry,object)
        @old_dump = old_dump
      end

      def noop?
        dump == old_dump
      end

      def dump
        @dump ||= registry.dump_object(object)
      end

      def old_key
        mapper.load_key(old_dump)
      end

      def run
        mapper.update(old_key,dump,old_dump)
      end
    end
  end
end
