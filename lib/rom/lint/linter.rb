module ROM
  module Lint
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
