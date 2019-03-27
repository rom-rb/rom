# frozen_string_literal: true

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
    # @api public
    class Linter
      # A failure raised by +complain+
      Failure = Class.new(StandardError)

      # Iterate over all lint methods
      #
      # @yield [String, ROM::Lint]
      #
      # @api public
      def self.each_lint
        return to_enum unless block_given?
        lints.each { |lint| yield lint, self }
      end

      # Run a lint method
      #
      # @param [String] name
      #
      # @raise [ROM::Lint::Linter::Failure] if linting fails
      #
      # @api public
      def lint(name)
        before_lint
        public_send name
        after_lint
        true # for assertions
      end

      private

      # Return a list a lint methods
      #
      # @return [String]
      #
      # @api private
      def self.lints
        public_instance_methods(true).grep(/^lint_/).map(&:to_s)
      end

      # Raise a failure if a lint verification fails
      #
      # @raise [ROM::Lint::Linter::Failure]
      #
      # @api private
      def complain(*args)
        raise Failure, *args
      end

      # Hook method executed before each lint method run
      #
      # @api private
      def before_lint
      end

      # Hook method executed after each lint method run
      #
      # @api private
      def after_lint
      end
    end
  end
end
