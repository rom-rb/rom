require 'pathname'

require 'dry/core/inflector'
require 'rom/types'
require 'rom/setup/auto_registration_strategies/base'

module ROM
  module AutoRegistrationStrategies
    class CustomNamespace < Base
      option :directory, type: PathnameType
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
        file_path << File.basename(file, ".rb")
      end

      def file_path
        File.dirname(file).split("/") - directory.to_s.split("/")
      end
    end
  end
end
