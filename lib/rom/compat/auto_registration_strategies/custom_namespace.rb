# frozen_string_literal: true

require "pathname"

require "rom/support/inflector"
require "rom/types"

require_relative "base"

module ROM
  module AutoRegistrationStrategies
    # Custom namespace strategy loads components and assumes they are defined
    # within the provided namespace
    #
    # @api private
    class CustomNamespace < Base
      # @!attribute [r] directory
      #   @return [Pathname] The path to dir with components
      option :directory, type: PathnameType

      # @!attribute [r] namespace
      #   @return [String] Name of a namespace
      option :namespace, type: Types::Strict::String

      # Loads components
      #
      # @api private
      def call
        parts = path_arr.map { |part| inflector.camelize(part) }
        potential = parts.map.with_index do |_, i|
          parts[(i - parts.size)..parts.size]
        end
        attempted = []

        potential.map do |path|
          const_fragment = path.join("::")

          constant = "#{namespace}::#{const_fragment}"

          return constant if ns_const.const_defined?(const_fragment)

          attempted << constant
        end

        # If we have reached this point, its means constant is not defined and
        # NameError will be thrown if we attempt to camelize something like:
        # `"#{namespace}::#{Inflector.camelize(filename)}"`
        # so we can assume naming convention was not respected in required
        # file.

        raise NameError, name_error_message(attempted)
      end

      private

      # @api private
      def name_error_message(attempted)
        "required file does not define expected constant name; either " \
        "register your constant explicitly of try following the path" \
        "naming convention like:\n\n\t- #{attempted.join("\n\t- ")}\n"
      end

      # @api private
      def filename
        Pathname(file).basename(".rb")
      end

      # @api private
      def ns_const
        @namespace_constant ||= inflector.constantize(namespace)
      end

      # @api private
      def path_arr
        file_path << filename
      end

      # @api private
      def file_path
        File.dirname(file).split("/") - directory.to_s.split("/")
      end
    end
  end
end
