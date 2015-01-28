require 'rom/commands'

module ROM
  module Memory
    module Commands
      module Create
        include ROM::Commands::Create

        def execute(tuple)
          attributes = input[tuple]
          validator.call(attributes)
          [relation.insert(attributes.to_h).to_a.last]
        end
      end

      module Update
        include ROM::Commands::Update

        def execute(params)
          attributes = input[params]
          validator.call(attributes)
          relation.map { |tuple| tuple.update(attributes.to_h) }
        end
      end

      module Delete
        include ROM::Commands::Delete

        def execute
          tuples = target.to_a
          tuples.each { |tuple| relation.delete(tuple) }
          tuples
        end
      end
    end
  end
end
