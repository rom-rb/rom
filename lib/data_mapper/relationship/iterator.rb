module DataMapper
  class Relationship

    module Iterator

      # Iterate over the loaded domain objects
      #
      # TODO
      #
      # remember relationships to include in a new object
      # (Relationship::IncludeDefinition) and make that
      # available on mapper instances. This will allow Tuples
      # to prepare multiple included relationships.
      #
      # @see Relation::Mapper#each
      #
      # @example
      #
      #   env[Person].include(:tasks).each do |person|
      #     person.tasks.each do |task|
      #       puts task.name
      #     end
      #   end
      #
      # @yield [object] the loaded domain objects
      #
      # @yieldparam [Object] object
      #   each loaded domain object
      #
      # @return [self]
      #
      # @api public
      def each
        return to_enum unless block_given?

        name = attributes.detect { |attribute|
          attribute.kind_of?(Mapper::Attribute::EmbeddedCollection)
        }.name

        Tuples.prepared(name, attributes, relation) do |tuple|
          yield(load(tuple))
        end

        self
      end

    end # module Iterator

  end # class Relationship
end # module DataMapper
