# frozen_string_literal: true

require "set"

require "dry/core/equalizer"
require_relative "constants"

module ROM
  # ROM's open structs are used for relations with empty schemas.
  # Such relations may exist in cases like using raw SQL strings
  # where schema was not explicitly defined using `view` DSL.
  #
  # @api public
  class OpenStruct
    include Dry::Equalizer(:__keys__, :to_h, inspect: false)

    include Enumerable

    IVAR = -> v { :"@#{v}" }
    WRITER = -> v { :"#{v}=" }

    # @api private
    attr_reader :__keys__

    # @api private
    def initialize(attributes = EMPTY_HASH, &block)
      @__keys__ = Set.new
      __load__(attributes)
    end

    # @api public
    def each
      __keys__.each { |key| yield(key, __get__(key)) }
    end

    # @api public
    def to_h
      map { |key, value| [key, value] }.to_h
    end
    alias_method :to_hash, :to_h

    # @api public
    def update(other)
      __load__(other)
    end

    # @api public
    def fetch(key, &block)
      to_h.fetch(key, &block)
    end

    # @api public
    def [](key)
      __send__(key)
    end

    # @api public
    def []=(key, value)
      __set__(key, value)
    end

    # @api public
    def key?(key)
      __keys__.include?(key)
    end

    # @api public
    def inspect
      %(#<#{self.class} #{to_h}>)
    end

    # @api private
    def respond_to_missing?(meth, include_private = false)
      super || key?(meth)
    end

    private

    # @api public
    def method_missing(meth, *args, &block)
      if meth.to_s.end_with?("=")
        key = meth.to_s.tr("=", "").to_sym

        if methods.include?(key)
          super
        else
          __set__(key, *args)
        end
      elsif key?(meth)
        __get__(meth)
      else
        super
      end
    end

    # @api private
    def __load__(attributes)
      Hash(attributes).each { |key, value| __set__(key, value) }
    end

    # @api private
    def __set__(key, value)
      __keys__ << key
      instance_variable_set(IVAR[key], value.is_a?(Hash) ? self.class.new(value) : value)
    end

    # @api private
    def __get__(key)
      instance_variable_get(IVAR[key])
    end
  end
end
