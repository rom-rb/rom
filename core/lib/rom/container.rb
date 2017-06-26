require 'dry/container'

require 'rom/cache'

module ROM
  # ROM container is an isolated environment with no global state where all
  # components are registered. Container objects provide access to your
  # relations, commands and mappers. ROM containers are usually configured and
  # handled via framework integrations, although it is easy to use them
  # standalone.
  #
  # There are 3 types of container setup:
  #
  # * Setup DSL - a simple block-based configuration which allows configuring
  #   all components and gives you back a container instance. This type is suitable
  #   for small scripts, or in some cases rake tasks
  # * Explicit setup - this type requires creating a configuration object,
  #   registering component classes (ie relation classes) and passing the config
  #   to container builder function. This type is suitable when your environment
  #   is not typical and you need full control over component registration
  # * Explicit setup with auto-registration - same as explicit setup but allows
  #   you to configure auto-registration mechanism which will register component
  #   classes for you, based on dir/file naming conventions. This is the most
  #   common type of setup that's used by framework integrations
  #
  # @example in-line setup
  #   rom = ROM.container(:sql, 'sqlite::memory') do |config|
  #     config.default.create_table :users do
  #       primary_key :id
  #       column :name, String, null: false
  #     end
  #
  #     config.relation(:users) do
  #       schema(infer: true)
  #
  #       def by_name(name)
  #         where(name: name)
  #       end
  #     end
  #   end
  #
  #   rom.relations[:users].insert(name: "Jane")
  #
  #   rom.relations[:users].by_name("Jane").to_a
  #   # [{:id=>1, :name=>"Jane"}]
  #
  # @example multi-step setup with explicit component classes
  #   config = ROM::Configuration.new(:sql, 'sqlite::memory')
  #
  #   config.default.create_table :users do
  #     primary_key :id
  #     column :name, String, null: false
  #   end
  #
  #   class Users < ROM::Relation[:sql]
  #     schema(:users, infer: true)
  #
  #     def by_name(name)
  #       where(name: name)
  #     end
  #   end
  #
  #   config.register_relation(Users)
  #
  #   rom = ROM.container(config)
  #
  #   rom.relations[:users].insert(name: "Jane")
  #
  #   rom.relations[:users].by_name("Jane").to_a
  #   # [{:id=>1, :name=>"Jane"}]
  #
  #
  # @example multi-step setup with auto-registration
  #   config = ROM::Configuration.new(:sql, 'sqlite::memory')
  #   config.auto_registration('./persistence', namespace: false)
  #
  #   config.default.create_table :users do
  #     primary_key :id
  #     column :name, String, null: false
  #   end
  #
  #   # ./persistence/relations/users.rb
  #   class Users < ROM::Relation[:sql]
  #     schema(infer: true)
  #
  #     def by_name(name)
  #       where(name: name)
  #     end
  #   end
  #
  #   rom = ROM.container(config)
  #
  #   rom.relations[:users].insert(name: "Jane")
  #
  #   rom.relations[:users].by_name("Jane").to_a
  #   # [{:id=>1, :name=>"Jane"}]
  #
  # @api public
  class Container
    include Dry::Container::Mixin
    include Dry::Equalizer(:gateways, :relations, :mappers, :commands)

    # @api private
    def self.new(gateways, relations, mappers, commands)
      container = super()

      caches = { mappers: Cache.new, commands: Cache.new }.freeze
      mapper_compiler = MapperCompiler.new(cache: caches[:mappers])

      configured_mappers = mappers.map { |r| r.with(compiler: mapper_compiler, cache: caches[:mappers]) }
      configured_commands = commands.map { |r| r.with(cache: caches[:commands], mappers: configured_mappers.key?(r.relation_name) ? configured_mappers[r.relation_name] : nil) }
      configured_relations = relations.map { |r| r.with(commands: commands[r.name.to_sym]) }

      container.register(:caches, caches)
      container.register(:gateways, gateways)
      container.register(:mappers, configured_mappers)
      container.register(:commands, configured_commands)
      container.register(:relations, configured_relations)

      container
    end

    # @api public
    def gateways
      self[:gateways]
    end

    # @api public
    def mappers
      self[:mappers]
    end

    # @api public
    def relations
      self[:relations]
    end

    # @api public
    def commands
      self[:commands]
    end

    # Disconnect all gateways
    #
    # @example
    #   rom = ROM.container(:sql, 'sqlite://my_db.sqlite')
    #   rom.relations[:users].insert(name: "Jane")
    #   rom.disconnect
    #
    # @return [Hash<Symbol=>Gateway>] a hash with disconnected gateways
    #
    # @api public
    def disconnect
      gateways.each_value(&:disconnect)
    end
  end
end
