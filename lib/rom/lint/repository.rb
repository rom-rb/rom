require 'rom/lint/linter'

module ROM
  module Lint
    class Repository < ROM::Lint::Linter
      attr_reader :repository, :uri

      def initialize(repository, uri)
        @repository = repository
        @uri = uri
      end

      def lint_schemes
        return if repository.respond_to? :schemes

        complain "#{repository}#schemes must be implemented"
      end

      def lint_schemes_is_an_array
        return if repository.schemes.instance_of? Array

        complain "#{repository}#schemes must return an array with supported schemes"
      end

      def lint_schemes_returns_any_supported_scheme
        return if repository.schemes.any?

        complain "#{repository}#schemes must return at least one supported scheme"
      end

      def lint_repository_setup
        return if repository_instance.instance_of? repository

        complain "#{repository}::setup must return a repository instance but \
                 returned #{repository_instance.inspect}"
      end

      def lint_dataset_reader
        return if repository_instance.respond_to? :[]

        complain "#{repository_instance} must respond to []"
      end

      def lint_dataset_predicate
        return if repository_instance.respond_to? :dataset?

        complain "#{repository_instance} must respond to dataset?"
      end

      def repository_instance
        ROM::Repository.setup(uri)
      end
    end
  end
end
