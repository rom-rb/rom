require 'transproc/registry'

module ROM
  class Changeset
    class Pipe
      extend Transproc::Registry

      attr_reader :processor

      def self.add_timestamps(data)
        now = Time.now
        data.merge(created_at: now, updated_at: now)
      end

      def self.touch(data)
        data.merge(updated_at: Time.now)
      end

      def initialize(processor = nil)
        @processor = processor
      end

      def >>(other)
        if processor
          self.class.new(processor >> other)
        else
          self.class.new(other)
        end
      end

      def call(data)
        if processor
          processor.call(data)
        else
          data
        end
      end
    end
  end
end
