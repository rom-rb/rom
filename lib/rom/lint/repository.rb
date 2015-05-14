require 'rom/lint/linter'

module ROM
  module Lint
    # Ensures that a [ROM::Repository] extension provides datasets through the
    # expected methods
    #
    # @api public
    class Repository < ROM::Lint::Linter
      # The repository identifier e.g. +:memory+
      #
      # @api public
      attr_reader :identifier

      # The repository class
      #
      # @api public
      attr_reader :repository

      # The optional URI
      #
      # @api public
      attr_reader :uri

      # Repository instance used in lint tests
      #
      # @api private
      attr_reader :repository_instance

      # Create a repository linter
      #
      # @param [Symbol] identifier
      # @param [Class] repository
      # @param [String] uri optional
      def initialize(identifier, repository, uri = nil)
        @identifier = identifier
        @repository = repository
        @uri = uri
        @repository_instance = setup_repository_instance
      end

      # Lint: Ensure that +repository+ setups up its instance
      #
      # @api public
      def lint_repository_setup
        return if repository_instance.instance_of? repository

        complain <<-STRING
          #{repository}.setup must return a repository instance but
          returned #{repository_instance.inspect}
        STRING
      end

      # Lint: Ensure that +repository_instance+ responds to +[]+
      #
      # @api public
      def lint_dataset_reader
        return if repository_instance.respond_to? :[]

        complain "#{repository_instance} must respond to []"
      end

      # Lint: Ensure that +repository_instance+ responds to +dataset?+
      #
      # @api public
      def lint_dataset_predicate
        return if repository_instance.respond_to? :dataset?

        complain "#{repository_instance} must respond to dataset?"
      end

      private

      # Setup repository instance
      #
      # @api private
      def setup_repository_instance
        if uri
          ROM::Repository.setup(identifier, uri)
        else
          ROM::Repository.setup(identifier)
        end
      end

      # Run Repository#disconnect
      #
      # @api private
      def after_lint
        super
        repository_instance.disconnect
      end
    end
  end
end
