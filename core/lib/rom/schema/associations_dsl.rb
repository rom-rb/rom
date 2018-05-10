require 'rom/associations/definitions'

module ROM
  class Schema
    # Additional schema DSL for definition SQL associations
    #
    # This DSL is exposed in `associations do .. end` blocks in schema defintions.
    #
    # @api public
    class AssociationsDSL < BasicObject
      # @!attribute [r] source
      #   @return [Relation::Name] The source relation
      attr_reader :source

      # @!attribute [r] registry
      #   @return [RelationRegistry] Relations registry from a rom container
      attr_reader :registry

      # @api private
      def initialize(source, &block)
        @source = source
        @registry = {}
        instance_exec(&block)
      end

      # Establish a one-to-many association
      #
      # @example using relation identifier
      #   has_many :tasks
      #
      # @example setting custom foreign key name
      #   has_many :tasks, foreign_key: :assignee_id
      #
      # @example with a :through option
      #   # this establishes many-to-many association
      #   has_many :tasks, through: :users_tasks
      #
      # @example using a custom view which overrides default one
      #   has_many :posts, view: :published, override: true
      #
      # @example using aliased association with a custom view
      #   has_many :posts, as: :published_posts, view: :published
      #
      # @example using custom target relation
      #   has_many :user_posts, relation: :posts
      #
      # @example using custom target relation and an alias
      #   has_many :user_posts, relation: :posts, as: :published, view: :published
      #
      # @param [Symbol] target The target relation identifier
      # @param [Hash] options A hash with additional options
      #
      # @return [Associations::OneToMany]
      #
      # @see #many_to_many
      #
      # @api public
      def one_to_many(target, options = {})
        if options[:through]
          many_to_many(target, options)
        else
          add(::ROM::Associations::Definitions::OneToMany.new(source, target, options))
        end
      end
      alias has_many one_to_many

      # Establish a one-to-one association
      #
      # @example using relation identifier
      #   one_to_one :addresses, as: :address
      #
      # @example with an intermediate join relation
      #   one_to_one :tasks, as: :priority_task, through: :assignments
      #
      # @param [Symbol] target The target relation identifier
      # @param [Hash] options A hash with additional options
      #
      # @return [Associations::OneToOne]
      #
      # @see #belongs_to
      #
      # @api public
      def one_to_one(target, options = {})
        if options[:through]
          one_to_one_through(target, options)
        else
          add(::ROM::Associations::Definitions::OneToOne.new(source, target, options))
        end
      end

      # Establish a one-to-one association with a :through option
      #
      # @example
      #   one_to_one_through :users, as: :author, through: :users_posts
      #
      # @return [Associations::OneToOneThrough]
      #
      # @api public
      def one_to_one_through(target, options = {})
        add(::ROM::Associations::Definitions::OneToOneThrough.new(source, target, options))
      end

      # Establish a many-to-many association
      #
      # @example using relation identifier
      #   many_to_many :tasks, through: :users_tasks
      #
      # @param [Symbol] target The target relation identifier
      # @param [Hash] options A hash with additional options
      #
      # @return [Associations::OneToOne]
      #
      # @see #one_to_many
      #
      # @api public
      def many_to_many(target, options = {})
        add(::ROM::Associations::Definitions::ManyToMany.new(source, target, options))
      end

      # Establish a many-to-one association
      #
      # @example using relation identifier
      #   many_to_one :users, as: :author
      #
      # @param [Symbol] target The target relation identifier
      # @param [Hash] options A hash with additional options
      #
      # @return [Associations::OneToOne]
      #
      # @see #one_to_many
      #
      # @api public
      def many_to_one(target, options = {})
        add(::ROM::Associations::Definitions::ManyToOne.new(source, target, options))
      end

      # Shortcut for many_to_one which sets alias automatically
      #
      # @example with an alias (relation identifier is inferred via pluralization)
      #   belongs_to :user
      #
      # @example with an explicit alias
      #   belongs_to :users, as: :author
      #
      # @see #many_to_one
      #
      # @return [Associations::ManyToOne]
      #
      # @api public
      def belongs_to(target, options = {})
        many_to_one(dataset_name(target), { as: target }.merge(options))
      end

      # Shortcut for one_to_one which sets alias automatically
      #
      # @example with an alias (relation identifier is inferred via pluralization)
      #   has_one :address
      #
      # @example with an explicit alias and a custom view
      #   has_one :posts, as: :priority_post, view: :prioritized
      #
      # @see #one_to_one
      #
      # @return [Associations::ManyToOne]
      #
      # @api public
      def has_one(target, options = {})
        one_to_one(dataset_name(target), { as: target }.merge(options))
      end

      # Return an association set for a schema
      #
      # @return [AssociationSet]
      #
      # @api private
      def call
        AssociationSet.new(registry)
      end

      private

      # @api private
      def add(association)
        key = association.as || association.name

        if registry.key?(key)
          ::Kernel.raise(
            ::ArgumentError,
            "association #{key.inspect} is already defined for #{source.to_sym.inspect} relation"
          )
        end

        registry[key] = association
      end

      # @api private
      def dataset_name(name)
        ::ROM.inflector.pluralize(name).to_sym
      end
    end
  end
end
