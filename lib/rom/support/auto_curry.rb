module ROM
  module AutoCurry
    def self.extended(klass)
      busy = false
      curried = klass.curried

      klass.define_singleton_method(:method_added) do |name|
        return if busy

        busy = true
        meth = instance_method(name)
        arity = meth.arity

        define_method(name) do |*args|
          if arity < 0 || arity == args.size
            meth.bind(self).(*args)
          else
            curried.new(self, name: name, curry_args: args, arity: arity)
          end
        end

        busy = false

        super(name)
      end
    end
  end
end
