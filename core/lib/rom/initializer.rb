require 'dry-initializer'

module ROM
  # @api private
  module Initializer
    # @api private
    module DefineWithHook
      # @api private
      def param(*)
        super

        __define_with__
      end

      # @api private
      def option(*)
        super

        __define_with__ unless method_defined?(:with)
      end

      # @api private
      def __define_with__
        seq_names = __initializer_mixin__.
                      instance_method(:__initialize__).
                      parameters[0...-1].
                      map { |_, name| name }.
                      join(', ')

        seq_names << ', ' unless seq_names.empty?

        undef_method(:with) if method_defined?(:with)

        class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def with(new_options = EMPTY_HASH)
            if new_options.empty?
              self
            else
              self.class.new(#{ seq_names }options.merge(new_options))
            end
          end
        RUBY
      end
    end

    # @api private
    def self.extended(base)
      base.extend(Dry::Initializer[undefined: false])
      base.extend(DefineWithHook)
      base.include(InstanceMethods)
    end

    # @api private
    module InstanceMethods
      # Instance options
      #
      # @return [Hash]
      #
      # @api public
      def options
        @__options__
      end
    end
  end
end
