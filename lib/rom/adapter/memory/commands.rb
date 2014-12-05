module ROM
  class Adapter
    class Memory < Adapter

      module Commands

        class Create
          include Concord.new(:relation, :options)

          attr_reader :validator, :input, :result

          RESULTS = [:one, :many].freeze

          def initialize(relation, options)
            super

            @validator = options.fetch(:validator)
            @input = options.fetch(:input)
            @result = options[:result] || :many

            if !RESULTS.include?(result)
              raise ArgumentError, "create command result #{@result.inspect} is not one of #{RESULTS.inspect}"
            end
          end

          def execute(tuple)
            attributes = input[tuple]
            validator.call(attributes)

            tuple = relation.insert(attributes.to_h).to_a.last

            if result == :one
              tuple
            else
              [tuple]
            end
          end
        end

        class Update
          include Concord.new(:relation, :input, :validator)

          def self.build(relation, definition)
            new(relation, definition.input, definition.validator)
          end

          def execute(params)
            attributes = input.new(params)
            validator.call(attributes)
            relation.map { |tuple| tuple.update(attributes.to_h) }
          end
          alias_method :set, :execute

          def new(*args, &block)
            self.class.new(relation.public_send(*args, &block), input, validator)
          end
        end

        class Delete
          include Concord.new(:relation, :target)

          def self.build(relation, target = relation)
            new(relation, target)
          end

          def execute
            target.to_a.each { |tuple| relation.delete(tuple) }

            relation
          end

          def new(*args, &block)
            self.class.new(relation, relation.public_send(*args, &block))
          end
        end

      end

    end
  end
end
