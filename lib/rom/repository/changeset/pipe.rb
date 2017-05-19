require 'transproc/registry'
require 'transproc/transformer'

module ROM
  class Changeset
    # Transproc Registry useful for pipe
    #
    # @api private
    module PipeRegistry
      extend Transproc::Registry

      import Transproc::HashTransformations

      def self.add_timestamps(data)
        now = Time.now
        data.merge(created_at: now, updated_at: now)
      end

      def self.touch(data)
        data.merge(updated_at: Time.now)
      end
    end

    # Composable data transformation pipe used by default in changesets
    #
    # @api private
    class Pipe < Transproc::Transformer[PipeRegistry]
      extend Initializer

      param :processor, default: -> { self.class.transproc }
      option :diff_processor, optional: true
      option :use_for_diff, optional: true, default: -> { true }

      def self.[](name)
        container[name]
      end

      def [](name)
        self.class[name]
      end

      def bind(context)
        if processor.is_a?(Proc)
          self.class.new(Pipe[-> *args { context.instance_exec(*args, &processor) }])
        else
          self
        end
      end

      def compose(other, for_diff: other.is_a?(Pipe) ? other.use_for_diff : false)
        new_proc = processor ? processor >> other : other

        if for_diff
          diff_proc = diff_processor ? diff_processor >> other : other
          new(new_proc, diff_processor: diff_proc)
        else
          new(new_proc)
        end
      end
      alias_method :>>, :compose

      def call(data)
        if processor
          processor.call(data)
        else
          data
        end
      end

      def for_diff(data)
        if diff_processor
          diff_processor.call(data)
        else
          data
        end
      end

      def with(opts)
        if opts.empty?
          self
        else
          Pipe.new(processor, options.merge(opts))
        end
      end

      def new(processor, opts = EMPTY_HASH)
        Pipe.new(processor, options.merge(opts))
      end
    end
  end
end
