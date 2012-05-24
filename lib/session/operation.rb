module Session
  # Base class for an operation
  class Operation
    attr_reader :object

    def initialize(session,object)
      @session,@object =session,object
    end

    def registry
      @session.instance_variable_get(:@registry)
    end

    def identity_map
      @session.instance_variable_get(:@identity_map)
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

      def initialize(session,object,old_dump)
        super(session,object)
        @old_dump = old_dump
      end

      def noop?
        dump == old_dump
      end

      def dump
        @dump ||= mapper.dump(object)
      end

      def old_key
        mapper.load_key(old_dump)
      end

      def run
        mapper.update(old_key,dump,old_dump)
        update_identity_map
      end

      def new_key
        mapper.dump_key(object)
      end

      def update_identity_map
        identity_map = self.identity_map
        identity_map.delete(old_key)
        identity_map[new_key]=object

        self
      end
    end
  end
end
