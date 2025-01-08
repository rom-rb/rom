# frozen_string_literal: true

require 'dry-initializer'

module ROM
  # @api private
  module Initializer
    # @api private
    module DefineWithHook
      # @api private
      def param(*, **) = super.tap { __define_with__ }

      # @api private
      def option(*, **)
        super.tap do
          __define_with__ unless method_defined?(:with)
        end
      end

      # @api private
      def __define_with__
        seq_names = dry_initializer
          .definitions
          .reject { |_, d| d.option }
          .keys
          .join(', ')

        seq_names << ', ' unless seq_names.empty?

        undef_method(:with) if method_defined?(:with)

        class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def with(**new_options)                                  # def with(**new_options)
            if new_options.empty?                                  #   if new_options.empty?
              self                                                 #     self
            else                                                   #   else
              self.class.new(#{seq_names}**options, **new_options) #     self.class.new(relation, **options, **new_options)
            end                                                    #   end
          end                                                      # end
        RUBY
      end
    end

    # @api private
    def self.extended(base)
      base.module_eval do
        undef_method(:with) if method_defined?(:with)

        extend(Dry::Initializer[undefined: false])
        extend(DefineWithHook)
        include(InstanceMethods)
      end
    end

    # @api private
    module InstanceMethods
      # Instance options
      #
      # @return [Hash]
      #
      # @api public
      def options
        @__options__ ||= self.class.dry_initializer.definitions.values.to_h do |item|
          [item.target, instance_variable_get(item.ivar)]
        end
      end

      define_method(:class, Kernel.instance_method(:class))
      define_method(:instance_variable_get, Kernel.instance_method(:instance_variable_get))

      # This makes sure we memoize options before an object becomes frozen
      #
      # @api public
      def freeze
        options
        super
      end
    end
  end
end
