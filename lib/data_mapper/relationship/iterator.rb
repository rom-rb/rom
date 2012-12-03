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
      # @see Mapper::Relation#each
      #
      # @example
      #
      #   DataMapper[Person].include(:tasks).each do |person|
      #     person.tasks.each do |task|
      #       puts task.name
      #     end
      #   end
      #
      # @yield [object] the loaded domain objects
      #
      # @yieldparam [Object] object
      #   the loaded domain object that is yielded
      #
      # @return [self]
      #
      # @api public
      def each
        return to_enum unless block_given?

        # TODO remove this
        name = attributes.detect { |attribute|
          attribute.kind_of?(Mapper::Attribute::EmbeddedCollection)
        }.name

        # TODO replace with Tuples.prepared(self)...
        Tuples.prepared(name, self).each_value do |tuple|
          yield(load(tuple))
        end

        self
      end

    end # module Iterator

  end # class Relationship
end # module DataMapper
