# frozen_string_literal: true

module ROM
  # Relation extension which provides auto-currying of relation view methods
  #
  # @api private
  module AutoCurry
    def self.extended(klass)
      klass.define_singleton_method(:method_added) do |name|
        return if auto_curry_busy?
        auto_curry_guard { auto_curry(name) }
        super(name)
      end
    end

    # @api private
    def auto_curry_guard
      @__auto_curry_busy__ = true
      yield
    ensure
      @__auto_curry_busy__ = false
    end

    # @api private
    def auto_curry_busy?
      @__auto_curry_busy__ ||= false
    end

    # @api private
    def auto_curried_methods
      @__auto_curried_methods__ ||= Set.new
    end

    # Auto-curry a method
    #
    # @param [Symbol] name The name of a method
    #
    # @api private
    def auto_curry(name, &block)
      arity = instance_method(name).arity

      return unless public_instance_methods.include?(name) && arity != 0

      mod = Module.new

      mod.module_eval do
        define_method(name) do |*args, &mblock|
          response =
            if arity < 0 || arity == args.size
              super(*args, &mblock)
            else
              self.class.curried.new(self, view: name, curry_args: args, arity: arity)
            end

          if block
            response.instance_exec(&block)
          else
            response
          end
        end
      end

      auto_curried_methods << name

      prepend(mod)
    end
  end
end
