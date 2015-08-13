module ROM
  # @api private
  module Configurable
    class Config
      WRITER_REGEXP = /=$/.freeze

      attr_reader :settings

      # @api private
      def initialize
        @settings = {}
      end

      # @api public
      def [](name)
        __send__(name)
      end

      # @api private
      def key?(name)
        settings.key?(name)
      end

      # @api private
      def freeze
        settings.each_value { |value| value.freeze }
        super
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        true
      end

      private

      # @api private
      def method_missing(meth, *args, &block)
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
        ! WRITER_REGEXP.match(name).nil?
      end
    end

    def config
      @config ||= Config.new
    end

    # @api public
    def configure
      yield(config)
    end
  end
end
