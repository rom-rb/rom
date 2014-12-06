module ROM
  module Commands

    class AbstractCommand
      VALID_RESULTS = [:one, :many].freeze

      attr_reader :relation, :options, :result

      # @api private
      def initialize(relation, options)
        @relation = relation
        @options = options

        @result = options[:result] || :many

        if !VALID_RESULTS.include?(result)
          raise InvalidOptionError.new(:result, VALID_RESULTS)
        end
      end

      # Call the command and return one or many tuples
      #
      # @api public
      def call(*args)
        tuples = execute(*args)

        if result == :one
          tuples.first
        else
          tuples
        end
      end

    end

  end
end

require 'rom/commands/create'
require 'rom/commands/update'
require 'rom/commands/delete'
