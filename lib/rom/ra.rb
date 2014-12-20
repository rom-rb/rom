require 'rom/ra/operation/join'
require 'rom/ra/operation/group'
require 'rom/ra/operation/wrap'

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

    # Groups two relations in-memory using group operation
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
    #       in_memory { group(join(tasks), tasks: [:title]) }
    #     end
    #   end
    #
    #   rom.relations.users.insert user_id: 1, name: 'Piotr'
    #   rom.relations.tasks.insert user_id: 1, title: 'Work'
    #   rom.relations.tasks.insert user_id: 1, title: 'Relax'
    #
    #   rom.relations.users.with_tasks.to_a
    #   => [{ user_id: 1, name: "Piotr",
    #         tasks: [{ title: "Relax" }, { title: "Work" }] }]
    #
    # @api public
    def group(*args)
      ra_with_options(*args) { |relation, options|
        Operation::Group.new(relation, options)
      }
    end

    # Embed one relation in another in-memory using wrap operation
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
    #     base_relation(:addresses) do
    #       repository :memory
    #
    #       attribute :user_id
    #       attribute :street
    #       attribute :zipcode
    #       attribute :city
    #     end
    #   end
    #
    #   setup.relation(:addresses)
    #
    #   setup.relation(:users) do
    #     def with_address
    #       in_memory do
    #         wrap(join(addresses), address: [:street, :zipcode, :city])
    #       end
    #     end
    #   end
    #
    #   rom = setup.finalize
    #
    #   rom.relations.users.insert user_id: 1, name: 'Piotr'
    #   rom.relations.addresses.insert user_id: 1, street: 'Street 1',
    #                                  zipcode: '123', city: 'Kraków'
    #
    #   rom.relations.users.with_address.to_a
    #   => [{ user_id: 1, name: "Piotr",
    #         address: { street: "Street 1", zipcode: "123", city: "Kraków" } }]
    #
    # @api public
    def wrap(*args)
      ra_with_options(*args) { |relation, options|
        Operation::Wrap.new(relation, options)
      }
    end

    private

    # @api private
    def ra_with_options(*args)
      relation =
        if args.size > 1
          args.first
        else
          self
        end

      options = args.last

      yield(relation, options)
    end
  end
end
