# frozen_string_literal: true

require 'transproc/transformer'

require 'rom/changeset/pipe_registry'

module ROM
  class Changeset
    # Composable data transformation pipe used by default in changesets
    #
    # @api private
    class Pipe < Transproc::Transformer[PipeRegistry]
      extend Initializer

      define!(&:identity)

      param :processor, optional: true

      option :use_for_diff, optional: true, default: -> { true }
      option :diff_processor, default: -> { self[processor] }

      def self.new(*args, **opts)
        if args.empty?
          initialize(**opts)
        else
          super
        end
      end

      def self.initialize(**opts)
        transformer = allocate
        transformer.__send__(:initialize, dsl.(transformer), **opts)
        transformer
      end

      def self.[](name_or_proc)
        container[name_or_proc]
      end

      def [](*args)
        self.class[*args]
      end

      def bind(context)
        if processor.is_a?(Proc)
          new(self.class[-> *args { context.instance_exec(*args, &processor) }])
        else
          self
        end
      end

      def compose(other, for_diff: other.is_a?(self.class) ? other.use_for_diff : false)
        new_proc = processor >> other

        if for_diff
          diff_proc = diff_processor >> (
            other.is_a?(self.class) ? other.diff_processor : other
          )

          new(new_proc, use_for_diff: true, diff_processor: diff_proc)
        else
          new(new_proc)
        end
      end
      alias_method :>>, :compose

      def call(data)
        processor.call(data)
      end

      def for_diff(data)
        use_for_diff ? diff_processor.call(data) : data
      end

      def new(processor, **opts)
        self.class.new(processor, **options, **opts)
      end
    end
  end
end
