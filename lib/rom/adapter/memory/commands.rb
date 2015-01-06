require 'rom/commands'

module ROM
  class Adapter
    class Memory < Adapter
      module Commands
        class Create < ROM::Commands::Create
          def execute(tuple)
            attributes = input[tuple]
            validator.call(attributes)
            [relation.insert(attributes.to_h).to_a.last]
          end
        end

        class Update < ROM::Commands::Update
          def execute(params)
            attributes = input[params]
            validator.call(attributes)
            relation.map { |tuple| tuple.update(attributes.to_h) }
          end
        end

        class Delete < ROM::Commands::Delete
          def execute
            tuples = target.to_a
            tuples.each { |tuple| relation.delete(tuple) }
            tuples
          end
        end
      end
    end
  end
end
