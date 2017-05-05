require 'pathname'

require 'dry/core/inflector'
require 'rom/types'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    class CustomNamespace < Base
      option :namespace, type: Types::Strict::String

      def call
        potential_child = []

        path_arr.reverse.each do |dir|
          fragment = Dry::Core::Inflector.camelize(dir)
          const = potential_child.unshift(fragment).join("::")

          break "#{namespace}::#{const}" if ns_const.const_defined?(const)
        end
      end

      private

      def ns_const
        @namespace_constant ||= Dry::Core::Inflector.constantize(namespace)
      end

      def path_arr
        dir, filename = File.split(file)
        dir.split("/")[1..-1] << File.basename(filename, ".rb")
      end
    end
  end
end
