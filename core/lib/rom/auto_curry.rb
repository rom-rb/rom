# frozen_string_literal: true

module ROM
  # Relation extension which provides auto-currying of relation view methods
  #
  # @api private
  module AutoCurry
    # @api private
    class Wrapper < ::Module
      def initialize(name, arity, &block)
        define_method(name) do |*args, **kwargs, &mblock|
          kwargs_size =
            if kwargs.empty?
              0
            else
              1
            end

          response =
            if arity.negative? || arity.eql?(args.size + kwargs_size)
              super(*args, **kwargs, &mblock)
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
    end

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
    def auto_curry(name, &)
      arity = instance_method(name).arity

      if public_instance_methods.include?(name) && arity != 0
        mod = Wrapper.new(name, arity, &)

        auto_curried_methods << name

        prepend(mod)
      else
        self
      end
    end
  end
end
