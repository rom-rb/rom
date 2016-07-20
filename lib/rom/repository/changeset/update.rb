module ROM
  class Changeset
    class Update < Changeset
      option :primary_key, reader: true

      def update?
        true
      end

      def create?
        false
      end

      def original
        @original ||= relation.fetch(primary_key)
      end

      def to_h
        pipe.call(diff)
      end
      alias_method :to_hash, :to_h

      def diff?
        ! diff.empty?
      end

      def clean?
        diff.empty?
      end

      def diff
        @diff ||=
          begin
            new_tuple = data.to_a
            ori_tuple = original.to_a

            Hash[new_tuple - (new_tuple & ori_tuple)]
          end
      end
    end

    def initialize(relation, data, options = EMPTY_HASH)
      @relation = relation
      @data = data
      super
    end

    def map(*steps)
      with(pipe: steps.reduce(pipe) { |a, e| a >> pipe.class[e] })
    end

    def to_h
      pipe.call(data)
    end
    alias_method :to_hash, :to_h

    def to_a
      [to_h]
    end
    alias_method :to_ary, :to_a

    def with(new_options)
      self.class.new(relation, data, options.merge(new_options))
    end

    private

    def respond_to_missing?(meth, include_private = false)
      super || data.respond_to?(meth)
    end

    def method_missing(meth, *args, &block)
      if data.respond_to?(meth)
        response = data.__send__(meth, *args, &block)

        if response.is_a?(Hash)
          self.class.new(relation, response, options)
        else
          response
        end
      else
        super
      end
    end
  end
end
