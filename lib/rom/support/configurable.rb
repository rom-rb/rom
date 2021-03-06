# frozen_string_literal: true

module ROM
  # This extension is only used for environment objects to configure arbitrary options, each
  # adapter can use them according to what they need.
  #
  # @api private
  module Configurable
    class Config
      include Enumerable

      WRITER_REGEXP = /=$/.freeze

      # @!attribute [r] settings
      #   @return [Hash] A hash with defined settings
      attr_reader :settings

      # @api private
      def initialize(settings = {})
        @settings = settings
      end

      # @api public
      def each(&block)
        settings.each(&block)
      end

      # @api public
      def each_key(&block)
        settings.each_key(&block)
      end

      # Return a setting
      #
      # @return [Mixed]
      #
      # @api public
      def [](name)
        if frozen?
          settings.fetch(name)
        else
          public_send(name)
        end
      end

      # @api private
      def key?(name)
        settings.key?(name)
      end

      # @api private
      def freeze
        settings.freeze
        super
      end

      # @api private
      def to_h(hash = settings)
        hash.map do |key, value|
          case value
          when Config then [key, value.to_h]
          when Hash then [key, to_h(hash)]
          when Array then [key, value.map { |item| item }]
          else
            [key, value]
          end
        end.to_h
      end
      alias_method :to_hash, :to_h

      # @api private
      def respond_to_missing?(name, *)
        if frozen?
          key?(name)
        else
          true
        end
      end

      # @api private
      def respond_to?(name, *)
        super || key?(name)
      end

      # @api private
      def dup
        self.class.new(dup_settings(settings))
      end

      # TODO: move to rom/compat
      #
      # @api private
      def use_logger(logger)
        self.logger = logger
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
        key = name.gsub(WRITER_REGEXP, "").to_sym

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

    # Return config instance
    #
    # @return [Config]
    #
    # @api private
    def config
      @config ||= Config.new
    end

    # Yield config instance
    #
    # @return [self]
    #
    # @api public
    def configure
      yield(config)
      self
    end
  end
end
