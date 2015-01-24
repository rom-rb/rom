require 'rom/lint/linter'

module ROM
  module Lint
    class Repository < ROM::Lint::Linter
      attr_reader :identifier, :repository, :uri

      def initialize(identifier, repository, uri = nil)
        @identifier = identifier
        @repository = repository
        @uri = uri
      end

      def lint_repository_setup
        return if repository_instance.instance_of? repository

        complain <<-STRING
          #{repository}::setup must return a repository instance but
          returned #{repository_instance.inspect}
        STRING
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
        if uri
          ROM::Repository.setup(identifier, uri)
        else
          ROM::Repository.setup(identifier)
        end
      end
    end
  end
end
