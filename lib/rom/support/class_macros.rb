module ROM
  module ClassMacros
    Undefined = Object.new.freeze

    def defines(*args)
      mod = Module.new

      args.each do |name|
        mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}(value = Undefined)
            if value == Undefined
              @#{name}
            else
              @#{name} = value
            end
          end
        RUBY

        extend(mod)
      end
    end
  end
end
