module ROM
  module ClassMacros
    Undefined = Object.new.freeze

    def defines(*args)
      mod = Module.new

      args.each do |name|
        mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          @@macros = [#{args.map(&:inspect).join(', ')}]

          def #{name}(value = Undefined)
            if value == Undefined
              @#{name}
            else
              @#{name} = value
            end
          end

          def inherited(klass)
            super
            macros.each do |name|
              klass.public_send(name, public_send(name))
            end
          end

          def macros
            @@macros || []
          end
        RUBY

        extend(mod)
      end
    end
  end
end
