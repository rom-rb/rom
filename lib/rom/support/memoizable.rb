# frozen_string_literal: true

module ROM
  # @api private
  module Memoizable
    MEMOIZED_HASH = {}.freeze

    module ClassInterface
      # @api private
      def memoize(*names)
        prepend(Memoizer.new(self, names))
      end

      def new(*)
        obj = super
        obj.instance_variable_set(:@__memoized__, MEMOIZED_HASH.dup)
        obj
      end
      ruby2_keywords(:new) if respond_to?(:ruby2_keywords, true)
    end

    def self.included(klass)
      super
      klass.extend(ClassInterface)
    end

    attr_reader :__memoized__

    # @api private
    class Memoizer < Module
      attr_reader :klass
      attr_reader :names

      # @api private
      def initialize(klass, names)
        @names = names
        @klass = klass
        define_memoizable_names!
      end

      private

      # @api private
      def define_memoizable_names!
        names.each do |name|
          meth = klass.instance_method(name)

          if meth.parameters.empty?
            define_method(name) do
              __memoized__[name] ||= super()
            end
          else
            define_method(name) do |*args|
              __memoized__[:"#{name}_#{args.hash}"] ||= super(*args)
            end
          end
        end
      end
    end
  end
end
