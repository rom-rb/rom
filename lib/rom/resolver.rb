# frozen_string_literal: true

require "rom/constants"

module ROM
  # @api private
  class Resolver
    include Enumerable

    attr_reader :components, :namespace

    # @api private
    def initialize(components: EMPTY_ARRAY, namespace: nil)
      @components = components
      @namespace = namespace
    end

    # @api private
    def namespaced(namespace)
      self.class.new(
        components: components, namespace: namespace
      )
    end

    # @api private
    def each
      if namespace
        components.public_send(namespace).each { |component| yield(component) }
      else
        components.each { |_, component| yield(component) }
      end
    end

    # @api private
    def call(key)
      comp = detect { |comp| comp.key == [namespace, key].compact.join(".") }

      if comp
        comp.build
      else
        # TODO: add auto-resolving
      end
    end
    alias_method :[], :call
  end
end
