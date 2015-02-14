module ROM
  module Lint
    # Base class for building linters that check source code
    #
    # Linters are used by authors of ROM adapters to verify that their
    # integration complies with the ROM api.
    #
    # Most of the time, authors won't need to construct linters directly
    # because the provided test helpers will automatically run when required
    # in tests and specs.
    #
    # @example
    #   require 'rom/lint/spec'
    #
    #
    # @public
    class Linter
      Failure = Class.new(StandardError)

      def self.lints
        public_instance_methods(true).grep(/^lint_/).map(&:to_s)
      end

      def self.each_lint
        return to_enum unless block_given?
        lints.each { |lint| yield lint, self }
      end

      def lint(name)
        public_send name
        true # for assertions
      end

      private

      def complain(*args)
        raise Failure, *args
      end
    end
  end
end
