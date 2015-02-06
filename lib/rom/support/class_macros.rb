module ROM
  module ClassMacros
    def defines(*args)
      mod = Module.new

      args.each do |name|
        mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}(value = Undefined)
            if value == Undefined
              defined?(@#{name}) && @#{name}
            else
              @#{name} = value
            end
          end
        RUBY
      end

      delegates = args.map { |name| "klass.#{name}(#{name})" }.join("\n")

      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def inherited(klass)
          super
          #{delegates}
        end
      RUBY

      extend(mod)
    end
  end
end
