module ROM
  class Adapter
    class Memory < Adapter

      module Commands

        class Create
          include Concord.new(:relation, :input, :validator)

          def self.build(relation, definition)
            new(relation, definition.input, definition.validator)
          end

          def execute(tuple)
            attributes = input.new(tuple)

            validation = validator.call(attributes)

            if validation.success?
              result = relation.insert(attributes.to_h)
              [result.to_a.last]
            else
              validation
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

            relation.map do |tuple|
              validation = validator.call(attributes)

              if validation.success?
                tuple.update(attributes.to_h)
              else
                validation
              end
            end
          end

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
