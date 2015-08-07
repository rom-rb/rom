module ROM
  module AutoCurry
    def self.extended(klass)
      busy = false

      klass.define_singleton_method(:method_added) do |name|
        return if busy
        busy = true
        auto_curry(name)
        busy = false
        super(name)
      end
    end

    def auto_curry(name)
      curried = self.curried
      meth = instance_method(name)
      arity = meth.arity

      define_method(name) do |*args|
        if arity < 0 || arity == args.size
          meth.bind(self).(*args)
        else
          curried.new(self, name: name, curry_args: args, arity: arity)
        end
      end
    end
  end
end
