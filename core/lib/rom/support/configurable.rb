module ROM
  # @api private
  module Configurable
    class Config
      WRITER_REGEXP = /=$/.freeze

      attr_reader :settings

      # @api private
      def initialize(settings = {})
        @settings = settings
      end

      # @api public
      def [](name)
        public_send(name)
      end

      # @api private
      def key?(name)
        settings.key?(name)
      end

      def to_hash
        settings
      end

      # @api private
      def freeze
        settings.each_value(&:freeze)
        super
      end

      # @api private
      def respond_to_missing?(_name, _include_private = false)
        true
      end

      def dup
        self.class.new(dup_settings(settings))
      end

      private

      def dup_settings(settings)
        settings.each_with_object({}) do |(key, value), new_settings|
          if value.is_a?(self.class)
            new_settings[key] = value.dup
          else
            new_settings[key] = value
          end
        end
      end

      # @api private
      def method_missing(meth, *args, &_block)
        return settings.fetch(meth, nil) if frozen?

        name = meth.to_s
        key = name.gsub(WRITER_REGEXP, '').to_sym

        if writer?(name)
          settings[key] = args.first
        else
          settings.fetch(key) { settings[key] = self.class.new }
        end
      end

      # @api private
      def writer?(name)
        !WRITER_REGEXP.match(name).nil?
      end
    end

    def config
      @config ||= Config.new
    end

    # @api public
    def configure
      yield(config)
      self
    end
  end
end
