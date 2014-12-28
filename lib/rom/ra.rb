require 'rom/ra/operation/join'

module ROM
  # Experimental DSL for in-memory relational operations
  #
  # @api private
  module RA
    # Join two relations in-memory using natural-join
    #
    # @example
    #
    #   require 'rom'
    #   require 'rom/adapter/memory'
    #
    #   setup = ROM.setup(memory: 'memory://localhost')
    #
    #   setup.schema do
    #     base_relation(:users) do
    #       repository :memory
    #
    #       attribute :user_id
    #       attribute :name
    #     end
    #
    #     base_relation(:tasks) do
    #       repository :memory
    #
    #       attribute :user_id
    #       attribute :title
    #     end
    #   end
    #
    #   setup.relation(:tasks)
    #
    #   setup.relation(:users) do
    #     def with_tasks
    #       in_memory { join(tasks) }
    #     end
    #   end
    #
    #   rom.relations.users.insert user_id: 1, name: 'Piotr'
    #   rom.relations.tasks.insert user_id: 1, title: 'Relax'
    #
    #   rom.relations.users.with_tasks.to_a
    #   => [{:user_id=>1, :name=>"Piotr", :title=>"Relax"}]
    #
    # @api public
    def join(*args)
      left, right = args.size > 1 ? args : [self, args.first]
      Operation::Join.new(left, right)
    end
  end
end
