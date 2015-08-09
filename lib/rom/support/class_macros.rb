module ROM
  # Internal support module for class-level settings
  #
  # @private
  module ClassMacros
    # Specify what macros a class will use
    #
    # @example
    #   class MyClass
    #     extend ROM::ClassMacros
    #
    #     defines :one, :two
    #
    #     one 1
    #     two 2
    #   end
    #
    #   class OtherClass < MyClass
    #     two 'two'
    #   end
    #
    #   MyClass.one # => 1
    #   MyClass.two # => 2
    #
    #   OtherClass.one # => 1
    #   OtherClass.two # => 'two'
    #
    # @api private
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
