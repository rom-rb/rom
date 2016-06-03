module ROM
  class Changeset
    attr_reader :relation

    attr_reader :data

    attr_reader :pipe

    class Pipe
      extend Transproc::Registry

      attr_reader :processor

      def self.add_timestamps(data)
        now = Time.now
        data.merge(created_at: now, updated_at: now)
      end

      def self.coerce(data, schema)
        schema[data]
      end

      def initialize(processor)
        @processor = processor
      end

      def >>(other)
        self.class.new(processor >> other)
      end

      def call(data)
        processor.call(data)
      end
    end

    def self.default_pipe(relation)
      Pipe.new(Pipe[:coerce, -> data { data }])
    end

    def initialize(relation, data, pipe = Changeset.default_pipe(relation))
      @relation = relation
      @data = data
      @pipe = pipe
    end

    def map(*steps)
      self.class.new(relation, data, steps.reduce(pipe) { |a, e| a >> pipe.class[e] })
    end

    def to_h
      pipe.call(data)
    end
    alias_method :to_hash, :to_h

    def to_a
      [to_h]
    end
    alias_method :to_ary, :to_a

    private

    def respond_to_missing?(meth, include_private = false)
      super || data.respond_to?(meth)
    end

    def method_missing(meth, *args, &block)
      if data.respond_to?(meth)
        response = data.__send__(meth, *args, &block)

        if response.is_a?(Hash)
          self.class.new(relation, response, pipe)
        else
          response
        end
      else
        super
      end
    end
  end
end
