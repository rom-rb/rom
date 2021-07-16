# frozen_string_literal: true

require "dry/configurable"
require "rom/constants"
require "rom/types"

module ROM
  # Component settings API
  #
  # @see https://dry-rb.org/gems/dry-configurable
  #
  # @api public
  module Configurable
    # @api private
    def self.included(klass)
      super

      klass.class_eval do
        include(Dry::Configurable)

        class << self
          prepend(ClassMethods)
        end
      end
    end

    # @api private
    def self.extended(klass)
      super

      klass.class_eval do
        extend(Dry::Configurable)

        class << self
          prepend(ClassMethods)
        end
      end
    end

    # @api private
    class Dry::Configurable::Config
      include Enumerable

      # @api private
      def each(&block)
        values.each(&block)
      end

      # @api private
      def inherit!(other)
        update(inherit(other))
      end

      # @api private
      def inherit(other)
        hash =
          if inherit?
            self[:inherit][:paths]
              .map(&other.method(:lookup))
              .map(&:to_h)
              .reduce { |left, right| left.merge(right) { |key, *vals| _compose(key, *vals) } }
          else
            other.to_h
          end.compact

        if hash.empty?
          hash
        else
          merge(hash.slice(*(_empty_keys - _compose_keys)))
            .merge(hash.slice(*_compose_keys)) { |key, *vals| _compose(key, *vals.reverse) }
        end
      end

      # @api private
      def _empty_keys
        keys - values.compact.keys
      end

      # @api private
      def _compose_keys
        inherit? ? self[:inherit][:compose] : EMPTY_ARRAY
      end

      # @api private
      def inherit?
        key?(:inherit)
      end

      # @api private
      def empty?
        values.compact.empty?
      end

      # @api private
      def lookup(path)
        Array(path).reduce(self) { |config, key| config[key] }
      end

      # @api private
      def _compose(key, lv, rv)
        if _compose_keys.include?(key)
          _settings[key].constructor.([lv, rv].compact)
        else
          rv
        end
      end

      # @api private
      def merge(other, &block)
        pristine.update(values.merge(other.to_h.slice(*keys), &block))
      end

      # @api private
      def key?(key)
        _settings.key?(key)
      end

      # @api private
      def keys
        _settings.keys
      end

      # @api private
      def fetch(*args, &block)
        values.fetch(*args, &block)
      end

      # @api private
      def to_h
        values
      end
      alias_method :to_hash, :to_h
    end

    # @api public
    module ClassMethods
      # @api public
      def setting(name, import: nil, **options)
        if import
          # TODO: it would be great if this could just be import.with(name: name)
          settings << import.class.new(
            name, input: import.input, default: import.default, **import.options
          )
        else
          super(name, **options)
        end
      end

      # @api public
      def settings
        _settings
      end

      # @api public
      def configure(namespace = nil, &block)
        if namespace
          super(&nil)
          block.(config[namespace])
        else
          super(&block)
        end
        self
      end
    end
  end
end
