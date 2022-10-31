# frozen_string_literal: true

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
          prepend(Methods)
          prepend(Methods::DSL)
        end
      end
    end

    # @api private
    def self.extended(klass)
      super

      klass.class_eval do
        extend(Dry::Configurable)

        class << self
          prepend(Methods)
          prepend(Methods::DSL)
        end
      end
    end

    # @api private
    module ConfigMethods
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
        hash = values.merge(other.to_h.slice(*keys)) { |key, left, right|
          if _constructors[key].is_a?(Constructors::Inherit)
            _constructors[key].(left, right)
          else
            left.nil? ? right : left
          end
        }
        merge(hash)
      end

      # @api private
      def join!(other, direction = :left)
        update(join(other, direction))
      end

      # @api private
      def join(other, direction = :left)
        hash = values.merge(other.to_h.slice(*keys)) { |key, left, right|
          if _constructors[key].is_a?(Constructors::Join)
            _constructors[key].(left, right, direction)
          else
            direction == :left ? left : right
          end
        }
        merge(hash)
      end

      # @api private
      def merge(other)
        dup.update(values.merge(other))
      end

      # @api private
      def empty?
        values.compact.empty?
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
      def fetch(...)
        values.fetch(...)
      end

      # @api private
      def to_h
        values
      end
      alias_method :to_hash, :to_h

      # @api private
      def freeze
        _constructors
        super
      end

      # @api private
      def _constructors
        @_constructors ||= _settings.map { |setting| [setting.name, setting.constructor] }.to_h
      end
    end

    module Constructors
      Default = ::Struct.new(:name) do
        def call(*args)
          return if args.compact.empty?

          block_given? ? yield(*args) : args.first
        end
        alias_method :[], :call
      end

      class Inherit < Default
        def call(*args)
          super { |left, right|
            case left
            when nil then right
            when Hash then right.merge(left)
            when Array then (right.map(&:dup) + left.map(&:dup)).uniq
            else
              left
            end
          }
        end
      end

      class Join < Default
        def call(*args)
          super { |left, right, direction|
            case direction
            when :left then [right, left]
            when :right then [left, right]
            else
              raise ArgumentError, "+#{direction}+ direction is not supported"
            end.compact.join(".")
          }
        end
      end
    end

    # @api public
    module Methods
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

      # @api private
      module DSL
        # @api private
        def setting(name, import: nil, inherit: false, join: false, default: Undefined, **options)
          if import
            setting_import(name, import, **options)
          elsif inherit
            setting(name, default: default, constructor: Constructors::Inherit.new(name), **options)
          elsif join
            setting(name, default: default, constructor: Constructors::Join.new(name), **options)
          else
            super(name, default: default, **options)
          end
        end

        # @api private
        def setting_import(name, setting)
          # TODO: it would be great if this could just be import.with(name: name)
          settings << setting.class.new(
            name, input: setting.input, default: setting.default, **setting.options
          )
        end
      end
    end

    # TODO: either extend functionality of dry-configurable or don't use it here after all
    Dry::Configurable::DSL.prepend(Methods::DSL)
    Dry::Configurable::Config.prepend(ConfigMethods)
  end
end
