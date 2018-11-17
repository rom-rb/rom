require 'dry/struct'

module ROM
  # Simple data-struct class
  #
  # ROM structs are plain data structures loaded by repositories.
  # They implement Hash protocol which means that they can be used
  # in places where Hash-like objects are supported.
  #
  # Repositories define subclasses of ROM::Struct automatically, they are
  # defined in the ROM::Struct namespace by default, but you set it up
  # to use your namespace/module as well.
  #
  # Structs are based on dry-struct gem, they include `schema` with detailed information
  # about attribute types returned from relations, thus can be introspected to build
  # additional functionality when desired.
  #
  # There is a caveat you should know about when working with structs. Struct classes
  # have names but at the same time they're anonymous, i.e. you can't get the User struct class
  # with ROM::Struct::User. ROM will create as many struct classes for User as needed,
  # they all will have the same name and ROM::Struct::User will be the common parent class for
  # them. Combined with the ability to provide your own namespace for structs this enables to
  # pre-define the parent class.
  #
  # @example accessing relation struct model
  #   rom = ROM.container(:sql, 'sqlite::memory') do |conf|
  #     conf.default.create_table(:users) do
  #       primary_key :id
  #       column :name, String
  #     end
  #   end
  #
  #   class UserRepo < ROM::Repository[:users]
  #   end
  #
  #   user_repo = UserRepo.new(rom)
  #
  #   # get auto-generated User struct
  #   model = user_repo.users.mapper.model
  #   # => ROM::Struct::User
  #
  #   # see struct's schema attributes
  #
  #   # model.schema[:id]
  #   # => #<Dry::Types::Constrained type=#<Dry::Types::Definition primitive=Integer options={}> options={:rule=>#<Dry::Logic::Rule::Predicate predicate=#<Method: Module(Dry::Logic::Predicates::Methods)#gt?> options={:args=>[0]}>, :meta=>{:primary_key=>true, :name=>:id, :source=>ROM::Relation::Name(users)}} rule=#<Dry::Logic::Rule::Predicate predicate=#<Method: Module(Dry::Logic::Predicates::Methods)#gt?> options={:args=>[0]}>>
  #
  #   model.schema[:name]
  #   # => #<Dry::Types::Sum left=#<Dry::Types::Constrained type=#<Dry::Types::Definition primitive=NilClass options={}> options={:rule=>#<Dry::Logic::Rule::Predicate predicate=#<Method: Module(Dry::Logic::Predicates::Methods)#type?> options={:args=>[NilClass]}>} rule=#<Dry::Logic::Rule::Predicate predicate=#<Method: Module(Dry::Logic::Predicates::Methods)#type?> options={:args=>[NilClass]}>> right=#<Dry::Types::Definition primitive=String options={}> options={:meta=>{:name=>:name, :source=>ROM::Relation::Name(users)}}>
  #
  # @example passing a namespace with an existing parent class
  #   module Entities
  #     class User < ROM::Struct
  #       def upcased_name
  #         name.upcase
  #       end
  #     end
  #   end
  #
  #   class UserRepo < ROM::Repository[:users]
  #     struct_namespace Entities
  #   end
  #
  #   user_repo = UserRepo.new(rom)
  #   user = user_repo.users.by_pk(1).one!
  #   user.name # => "Jane"
  #   user.upcased_name # => "JANE"
  #
  # @see http://dry-rb.org/gems/dry-struct dry-struct
  # @see http://dry-rb.org/gems/dry-types dry-types
  #
  # @api public
  class Struct < Dry::Struct
    MissingAttribute = Class.new(NameError) do
      def initialize(&block)
        super
        @message_proc = block
      end

      def message
        @message_proc.call
      end
    end

    # Return attribute value
    #
    # @param [Symbol] name The attribute name
    #
    # @api public
    def fetch(name)
      __send__(name)
    end

    # @api private
    def respond_to_missing?(*)
      super
    end

    private

    def method_missing(*)
      super
    rescue NameError => error
      raise MissingAttribute.new { "#{ error.message } (attribute not loaded?)" }
    end
  end
end
