require 'rom/support/publisher'

module ROM
  module Support
    module GuardedInheritanceHook
      def self.extended(base)
        base.class_eval <<-RUBY
          class << self
            include ROM::Support::Publisher

            def inherited(klass)
              super
              return if klass.superclass == #{base}
              #{base}.__send__(:broadcast, :inherited, klass)
            end
          end
        RUBY
      end
    end
  end
end
