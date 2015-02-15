require 'rom/commands'

module ROM
  module Memory
    # Memory adapter commands namespace
    #
    # @public
    module Commands
      # In-memory create command
      #
      # @public
      class Create < ROM::Commands::Create
        # @see ROM::Commands::Create#execute
        def execute(tuple)
          attributes = input[tuple]
          validator.call(attributes)
          [relation.insert(attributes.to_h).to_a.last]
        end
      end

      # In-memory update command
      #
      # @public
      class Update < ROM::Commands::Update
        # @see ROM::Commands::Update#execute
        def execute(params)
          attributes = input[params]
          validator.call(attributes)
          relation.map { |tuple| tuple.update(attributes.to_h) }
        end
      end

      # In-memory delete command
      #
      # @public
      class Delete < ROM::Commands::Delete
        # @see ROM::Commands::Delete#execute
        def execute
          tuples = target.to_a
          tuples.each { |tuple| relation.delete(tuple) }
          tuples
        end
      end
    end
  end
end
