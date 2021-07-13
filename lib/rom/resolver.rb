# frozen_string_literal: true

require "rom/constants"

module ROM
  # @api private
  class Resolver
    include Enumerable

    attr_reader :components, :namespace

    # @api private
    def initialize(components: EMPTY_ARRAY, namespace: nil)
      @components = Array(components)
      @namespace = namespace ? String(namespace) : namespace
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
        components.each do |component|
          yield(component) if component.namespace.start_with?(namespace)
        end
      else
        components.each do |component|
          yield(component)
        end
      end
    end

    # @api private
    def key?(key)
      if namespace
        keys.include?("#{namespace}.#{key}") || keys.include?(key)
      else
        keys.include?(key)
      end
    end

    # @api private
    def keys
      map(&:key)
    end

    # @api private
    def call(key, &fallback)
      qualified_key = [namespace, key].compact.join(".")

      comp = detect { |comp| comp.key == qualified_key }

      if comp
        comp.build
      elsif fallback
        fallback.()
      elsif root?(key)
        namespaced(qualified_key)
      else
        raise "+#{qualified_key}+ not found"
      end
    end
    alias_method :[], :call

    private

    # @api private
    def root?(key)
      map(&:relation_id).uniq.include?(key)
    end
  end
end
