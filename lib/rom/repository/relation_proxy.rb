require 'rom/initializer'
require 'rom/relation/materializable'

require 'rom/repository/relation_proxy/combine'
require 'rom/repository/relation_proxy/wrap'

module ROM
  class Repository
    # RelationProxy decorates a relation and automatically generates mappers that
    # will map raw tuples into rom structs
    #
    # Relation proxies are being registered within repositories so typically there's
    # no need to instantiate them manually.
    #
    # @api public
    class RelationProxy
      extend Initializer
      include Relation::Materializable

      include RelationProxy::Combine
      include RelationProxy::Wrap

      RelationRegistryType = Types.Definition(RelationRegistry).constrained(type: RelationRegistry)

      # @!attribute [r] relation
      #   @return [Relation, Relation::Composite, Relation::Graph, Relation::Curried] The decorated relation object
      param :relation

      option :name, type:  Types::Strict::Symbol
      option :mappers, default: -> { MapperBuilder.new }
      option :meta, default: -> { EMPTY_HASH }
      option :registry, type: RelationRegistryType, default: -> { RelationRegistry.new }
      option :auto_struct, default: -> { true }

      # Relation name
      #
      # @return [ROM::Relation::Name]
      #
      # @api public
      def name
        @name ? relation.name.with(@name) : relation.name
      end

      # Materializes wrapped relation and sends it through a mapper
      #
      # For performance reasons a combined relation will skip mapping since
      # we only care about extracting key values for combining
      #
      # @api public
      def call(*args)
        ((combine? || composite?) ? relation : (relation >> mapper)).call(*args)
      end

      # Maps the wrapped relation with other mappers available in the registry
      #
      # @overload map_with(model)
      #   Map tuples to the provided custom model class
      #
      #   @example
      #     users.as(MyUserModel)
      #
      #   @param [Class>] model Your custom model class
      #
      # @overload map_with(*mappers)
      #   Map tuples using registered mappers
      #
      #   @example
      #     users.map_with(:my_mapper, :my_other_mapper)
      #
      #   @param [Array<Symbol>] mappers A list of mapper identifiers
      #
      # @overload map_with(*mappers, auto_map: true)
      #   Map tuples using auto-mapping and custom registered mappers
      #
      #   If `auto_map` is enabled, your mappers will be applied after performing
      #   default auto-mapping. This means that you can compose complex relations
      #   and have them auto-mapped, and use much simpler custom mappers to adjust
      #   resulting data according to your requirements.
      #
      #   @example
      #     users.map_with(:my_mapper, :my_other_mapper, auto_map: true)
      #
      #   @param [Array<Symbol>] mappers A list of mapper identifiers
      #
      # @return [RelationProxy] A new relation proxy with pipelined relation
      #
      # @api public
      def map_with(*names, **opts)
        if names.size == 1 && names[0].is_a?(Class)
          with(meta: meta.merge(model: names[0]))
        elsif names.size > 1 && names.any? { |name| name.is_a?(Class) }
          raise ArgumentError, 'using custom mappers and a model is not supported'
        else
          if opts[:auto_map]
            mappers = [mapper, *names.map { |name| relation.mappers[name] }]
            mappers.reduce(self) { |a, e| a >> e }
          else
            names.reduce(self) { |a, e| a >> relation.mappers[e] }
          end
        end
      end
      alias_method :as, :map_with

      # Return a new graph with adjusted node returned from a block
      #
      # @example with a node identifier
      #   aggregate(:tasks).node(:tasks) { |tasks| tasks.prioritized }
      #
      # @example with a nested path
      #   aggregate(tasks: :tags).node(tasks: :tags) { |tags| tags.where(name: 'red') }
      #
      # @param [Symbol] name The node relation name
      #
      # @yieldparam [RelationProxy] The relation node
      # @yieldreturn [RelationProxy] The new relation node
      #
      # @return [RelationProxy]
      #
      # @api public
      def node(name, &block)
        if name.is_a?(Symbol) && !nodes.map { |n| n.name.relation }.include?(name)
          raise ArgumentError, "#{name.inspect} is not a valid aggregate node name"
        end

        new_nodes = nodes.map { |node|
          case name
          when Symbol
            name == node.name.relation ? yield(node) : node
          when Hash
            other, *rest = name.flatten(1)
            if other == node.name.relation
              nodes.detect { |n| n.name.relation == other }.node(*rest, &block)
            else
              node
            end
          else
            node
          end
        }

        with_nodes(new_nodes)
      end

      # Return a string representation of this relation proxy
      #
      # @return [String]
      #
      # @api public
      def inspect
        %(#<#{relation.class} name=#{name} dataset=#{dataset.inspect}>)
      end

      # Infers a mapper for the wrapped relation
      #
      # @return [ROM::Mapper]
      #
      # @api private
      def mapper
        mappers[to_ast]
      end

      # Returns a new instance with new options
      #
      # @param new_options [Hash]
      #
      # @return [RelationProxy]
      #
      # @api private
      def with(new_options)
        __new__(relation, options.merge(new_options))
      end

      # Returns if this relation is combined aka a relation graph
      #
      # @return [Boolean]
      #
      # @api private
      def combine?
        meta[:combine_type]
      end

      # Return if this relation is a composite
      #
      # @return [Boolean]
      #
      # @api private
      def composite?
        relation.is_a?(Relation::Composite)
      end

      # @return [Symbol] The wrapped relation's adapter identifier ie :sql or :http
      #
      # @api private
      def adapter
        relation.class.adapter
      end

      # Returns AST for the wrapped relation
      #
      # @return [Array]
      #
      # @api private
      def to_ast
        @to_ast ||=
          begin
            attr_ast = schema.map { |attr| [:attribute, attr] }

            meta = self.meta.merge(dataset: base_name.dataset)
            meta.update(model: false) unless meta[:model] || auto_struct
            meta.delete(:wraps)

            header = attr_ast + nodes_ast + wraps_ast

            [:relation, [base_name.relation, meta, [:header, header]]]
          end
      end

      # @api private
      def respond_to_missing?(meth, _include_private = false)
        relation.respond_to?(meth) || super
      end

      private

      # @api private
      def schema
        if meta[:wrap]
          relation.schema.wrap
        else
          relation.schema.reject(&:wrapped?)
        end
      end

      # @api private
      def base_name
        relation.base_name
      end

      # @api private
      def nodes_ast
        @nodes_ast ||= nodes.map(&:to_ast)
      end

      # @api private
      def wraps_ast
        @wraps_ast ||= wraps.map(&:to_ast)
      end

      # Return a new instance with another relation and options
      #
      # @return [RelationProxy]
      #
      # @api private
      def __new__(relation, new_options = EMPTY_HASH)
        self.class.new(
          relation, new_options.size > 0 ? options.merge(new_options) : options
        )
      end

      # Return all nodes that this relation combines
      #
      # @return [Array<RelationProxy>]
      #
      # @api private
      def nodes
        relation.graph? ? relation.nodes : EMPTY_ARRAY
      end

      # Return all nodes that this relation wraps
      #
      # @return [Array<RelationProxy>]
      #
      # @api private
      def wraps
        meta.fetch(:wraps, EMPTY_ARRAY)
      end

      # Forward to relation and wrap it with proxy if response was a relation too
      #
      # TODO: this will be simplified once ROM::Relation has lazy-features built-in
      #       and ROM::Lazy is gone
      #
      # @api private
      def method_missing(meth, *args, &block)
        if relation.respond_to?(meth)
          result = relation.__send__(meth, *args, &block)

          if result.kind_of?(Relation::Materializable) && !result.is_a?(Relation::Loaded)
            __new__(result)
          else
            result
          end
        else
          raise NoMethodError, "undefined method `#{meth}' for #{relation.class.name}"
        end
      end
    end
  end
end
