require 'dry/equalizer'

require 'rom/initializer'
require 'rom/support/memoizable'

module ROM
  # Schema attributes provide meta information about types and an API
  # for additional operations. This class can be extended by adapters to provide
  # database-specific features. In example rom-sql provides SQL::Attribute
  # with more features like creating SQL expressions for queries.
  #
  # Schema attributes are accessible through canonical relation schemas and
  # instance-level schemas.
  #
  # @api public
  class Attribute
    include Dry::Equalizer(:type, :options)
    include Memoizable

    extend Initializer

    # @!attribute [r] type
    #   @return [Dry::Types::Definition, Dry::Types::Sum, Dry::Types::Constrained] The attribute's type object
    param :type

    # @api private
    def [](input)
      type[input]
    end

    # Return true if this attribute type is a primary key
    #
    # @example
    #   class Users < ROM::Relation[:memory]
    #     schema do
    #       attribute :id, Types::Integer
    #       attribute :name, Types::String
    #
    #       primary_key :id
    #     end
    #   end
    #
    #   Users.schema[:id].primary_key?
    #   # => true
    #
    #   Users.schema[:name].primary_key?
    #   # => false
    #
    # @return [TrueClass,FalseClass]
    #
    # @api public
    def primary_key?
      meta[:primary_key].equal?(true)
    end

    # Return true if this attribute type is a foreign key
    #
    # @example
    #   class Tasks < ROM::Relation[:memory]
    #     schema do
    #       attribute :id, Types::Integer
    #       attribute :user_id, Types.ForeignKey(:users)
    #     end
    #   end
    #
    #   Users.schema[:user_id].foreign_key?
    #   # => true
    #
    #   Users.schema[:id].foreign_key?
    #   # => false
    #
    # @return [TrueClass,FalseClass]
    #
    # @api public
    def foreign_key?
      meta[:foreign_key].equal?(true)
    end

    # Return true if this attribute type is a foreign key
    #
    # @example
    #   class Tasks < ROM::Relation[:memory]
    #     schema do
    #       attribute :user_id, Types::Integer.meta(alias: :id)
    #       attribute :name, Types::String
    #     end
    #   end
    #
    #   Users.schema[:user_id].aliased?
    #   # => true
    #
    #   Users.schema[:name].aliased?
    #   # => false
    #
    # @return [TrueClass,FalseClass]
    #
    # @api public
    def aliased?
      !meta[:alias].nil?
    end

    # Return source relation of this attribute type
    #
    # @example
    #   class Tasks < ROM::Relation[:memory]
    #     schema do
    #       attribute :id, Types::Integer
    #       attribute :user_id, Types.ForeignKey(:users)
    #     end
    #   end
    #
    #   Users.schema[:id].source
    #   # => :tasks
    #
    #   Users.schema[:user_id].source
    #   # => :tasks
    #
    # @return [Symbol, Relation::Name]
    #
    # @api public
    def source
      meta[:source]
    end

    # Return target relation of this attribute type
    #
    # @example
    #   class Tasks < ROM::Relation[:memory]
    #     schema do
    #       attribute :id, Types::Integer
    #       attribute :user_id, Types.ForeignKey(:users)
    #     end
    #   end
    #
    #   Users.schema[:id].target
    #   # => nil
    #
    #   Users.schema[:user_id].target
    #   # => :users
    #
    # @return [NilClass, Symbol, Relation::Name]
    #
    # @api public
    def target
      meta[:target]
    end

    # Return the canonical name of this attribute name
    #
    # This *always* returns the name that is used in the datastore, even when
    # an attribute is aliased
    #
    # @example
    #   class Tasks < ROM::Relation[:memory]
    #     schema do
    #       attribute :user_id, Types::Integer.meta(alias: :id)
    #       attribute :name, Types::String
    #     end
    #   end
    #
    #   Users.schema[:id].name
    #   # => :id
    #
    #   Users.schema[:user_id].name
    #   # => :user_id
    #
    # @return [Symbol]
    #
    # @api public
    def name
      meta[:name]
    end

    # Return tuple key
    #
    # When schemas are projected with aliased attributes, we need a simple access to tuple keys
    #
    # @example
    #   class Tasks < ROM::Relation[:memory]
    #     schema do
    #       attribute :user_id, Types::Integer.meta(alias: :id)
    #       attribute :name, Types::String
    #     end
    #   end
    #
    #   Users.schema[:id].key
    #   # :id
    #
    #   Users.schema.project(Users.schema[:id].aliased(:user_id)).key
    #   # :user_id
    #
    # @return [Symbol]
    #
    # @api public
    def key
      meta[:alias] || name
    end

    # Return attribute's alias
    #
    # @example
    #   class Tasks < ROM::Relation[:memory]
    #     schema do
    #       attribute :user_id, Types::Integer.meta(alias: :id)
    #       attribute :name, Types::String
    #     end
    #   end
    #
    #   Users.schema[:user_id].alias
    #   # => :user_id
    #
    #   Users.schema[:name].alias
    #   # => nil
    #
    # @return [NilClass,Symbol]
    #
    # @api public
    def alias
      meta[:alias]
    end

    # Return new attribute type with provided alias
    #
    # @example
    #   class Tasks < ROM::Relation[:memory]
    #     schema do
    #       attribute :user_id, Types::Integer
    #       attribute :name, Types::String
    #     end
    #   end
    #
    #   aliased_user_id = Users.schema[:user_id].aliased(:id)
    #
    #   aliased_user_id.aliased?
    #   # => true
    #
    #   aliased_user_id.name
    #   # => :user_id
    #
    #   aliased_user_id.alias
    #   # => :id
    #
    # @param [Symbol] name The alias
    #
    # @return [Attribute]
    #
    # @api public
    def aliased(name)
      meta(alias: name)
    end
    alias_method :as, :aliased

    # Return new attribute type with an alias using provided prefix
    #
    # @example
    #   class Users < ROM::Relation[:memory]
    #     schema do
    #       attribute :id, Types::Integer
    #       attribute :name, Types::String
    #     end
    #   end
    #
    #   prefixed_id = Users.schema[:id].prefixed
    #
    #   prefixed_id.aliased?
    #   # => true
    #
    #   prefixed_id.name
    #   # => :id
    #
    #   prefixed_id.alias
    #   # => :users_id
    #
    #   prefixed_id = Users.schema[:id].prefixed(:user)
    #
    #   prefixed_id.alias
    #   # => :user_id
    #
    # @param [Symbol] prefix The prefix (defaults to source.dataset)
    #
    # @return [Attribute]
    #
    # @api public
    def prefixed(prefix = source.dataset)
      aliased(:"#{prefix}_#{name}")
    end

    # Return if the attribute type is from a wrapped relation
    #
    # Wrapped attributes are used when two schemas from different relations
    # are merged together. This way we can identify them easily and handle
    # correctly in places like auto-mapping.
    #
    # @api public
    def wrapped?
      meta[:wrapped].equal?(true)
    end

    # Return attribute type wrapped for the specified relation name
    #
    # @param [Symbol] name The name of the source relation (defaults to source.dataset)
    #
    # @return [Attribute]
    #
    # @api public
    def wrapped(name = source.dataset)
      prefixed(name).meta(wrapped: true)
    end

    # Return attribute type with additional meta information
    #
    # Return meta information hash if no opts are provided
    #
    # @param [Hash] opts The meta options
    #
    # @return [Attribute]
    #
    # @api public
    def meta(opts = nil)
      if opts
        self.class.new(type.meta(opts))
      else
        type.meta
      end
    end

    # Return string representation of the attribute type
    #
    # @return [String]
    #
    # @api public
    def inspect
      %(#<#{self.class}[#{type.name}] #{meta.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')}>)
    end
    alias_method :pretty_inspect, :inspect

    # Check if the attribute type is equal to another
    #
    # @param [Dry::Type, Attribute] other
    #
    # @return [TrueClass,FalseClass]
    #
    # @api public
    def eql?(other)
      other.is_a?(self.class) ? super : type.eql?(other)
    end

    # Return if this attribute type has additional attribute type for reading
    # tuple values
    #
    # @return [TrueClass, FalseClass]
    #
    # @api private
    def read?
      ! meta[:read].nil?
    end

    # Return read type
    #
    # @return [Dry::Types::Type]
    #
    # @api private
    def to_read_type
      read? ? meta[:read] : type
    end

    # Return write type
    #
    # @return [Dry::Types::Type]
    #
    # @api private
    def to_write_type
      type
    end

    # Return nullable attribute
    #
    # @return [Attribute]
    #
    # @api public
    def optional
      sum = self.class.new(super, options)
      read? ? sum.meta(read: meta[:read].optional) : sum
    end

    # @api private
    def respond_to_missing?(name, include_private = false)
      type.respond_to?(name) || super
    end

    # Return AST for the type
    #
    # @return [Array]
    #
    # @api public
    def to_ast
      [:attribute, [name, type.to_ast(meta: false), meta_ast]]
    end

    # Return AST for the read type
    #
    # @return [Array]
    #
    # @api public
    def to_read_ast
      [:attribute, [name, to_read_type.to_ast(meta: false), meta_ast]]
    end

    # @api private
    def meta_ast
      meta_keys = %i(wrapped alias primary_key)
      ast = meta.select { |k, _| meta_keys.include?(k) }
      ast[:source] = source.to_sym if source
      ast
    end

    memoize :to_ast, :to_read_ast, :meta_ast

    private

    # @api private
    def method_missing(meth, *args, &block)
      if type.respond_to?(meth)
        response = type.__send__(meth, *args, &block)

        if response.is_a?(type.class)
          self.class.new(response, options)
        else
          response
        end
      else
        super
      end
    end
  end
end
