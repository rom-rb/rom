require 'dry/struct'

module ROM
  # Simple data-struct class
  #
  # ROM structs are plain data structures loaded by repositories.
  # They implement Hash protocol which means that they can be used
  # in places where Hash-like objects are supported.
  #
  # Repositories define subclasses of ROM::Struct automatically, they are not
  # defined as constants in any module, instead, generated mappers are configured
  # to use anonymous struct classes as models.
  #
  # Structs are based on dry-struct gem, they include `schema` with detailed information
  # about attribute types returned from relations, thus can be introspected to build
  # additional functionality when desired.
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
  #   # => ROM::Struct[User]
  #
  #   # see struct's schema attributes
  #
  #   # model.schema[:id]
  #   # => #<Dry::Types::Constrained type=#<Dry::Types::Definition primitive=Integer options={}> options={:rule=>#<Dry::Logic::Rule::Predicate predicate=#<Method: Module(Dry::Logic::Predicates::Methods)#gt?> options={:args=>[0]}>, :meta=>{:primary_key=>true, :name=>:id, :source=>ROM::Relation::Name(users)}} rule=#<Dry::Logic::Rule::Predicate predicate=#<Method: Module(Dry::Logic::Predicates::Methods)#gt?> options={:args=>[0]}>>
  #
  #   model.schema[:name]
  #   # => #<Dry::Types::Sum left=#<Dry::Types::Constrained type=#<Dry::Types::Definition primitive=NilClass options={}> options={:rule=>#<Dry::Logic::Rule::Predicate predicate=#<Method: Module(Dry::Logic::Predicates::Methods)#type?> options={:args=>[NilClass]}>} rule=#<Dry::Logic::Rule::Predicate predicate=#<Method: Module(Dry::Logic::Predicates::Methods)#type?> options={:args=>[NilClass]}>> right=#<Dry::Types::Definition primitive=String options={}> options={:meta=>{:name=>:name, :source=>ROM::Relation::Name(users)}}>
  #
  # @see http://dry-rb.org/gems/dry-struct dry-struct
  # @see http://dry-rb.org/gems/dry-types dry-types
  #
  # @api public
  class Struct < Dry::Struct
    # Returns a short string representation
    #
    # @return [String]
    #
    # @api public
    def to_s
      "#<#{self.class}:0x#{(object_id << 1).to_s(16)}>"
    end

    # Return attribute value
    #
    # @param [Symbol] name The attribute name
    #
    # @api public
    def fetch(name)
      __send__(name)
    end
  end
end
