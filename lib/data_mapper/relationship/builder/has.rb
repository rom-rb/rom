module DataMapper
  class Relationship
    module Builder

      class Has

        # Build a {OneToOne}, {OneToMany} or {ManyToMany} relationship
        #
        # @see Relationship::OneToMany
        # @see Relationship::OneToOne
        # @see Relationship::ManyToMany
        #
        # TODO: add specs
        #
        # @param [Mapper] source
        #   the mapper establishing this relationship
        #
        # @param [Fixnum, Range] cardinality
        #   the relationship's cardinality
        #
        # @param [Symbol] name
        #   the relationship's name
        #
        # @param [::Class] target_model
        #   the class of the object this relationship is pointing to
        #
        # @param [Hash] options
        #   the relationship's options
        #
        # @option options [Symbol, Array<Symbol>] :source_key
        #   the source_model's attributes to join on
        #
        # @option options [Symbol, Array<Symbol>] :target_key
        #   the target_model's attributes to join on
        #
        # @option options [Symbol] :through
        #   the name of the relationship to "go through" in case of M:N
        #
        # @return [OneToMany, OneToOne, ManyToMany]
        #
        # @api private
        def self.build(source, cardinality, name, target_model, options = {}, &op)
          via      = options[:through]
          min, max = extract_min_max(cardinality, name)

          options.update(:min => min, :max => max, :operation => op)

          klass =
            if max > 1
              if via
                Relationship::ManyToMany
              else
                Relationship::OneToMany
              end
            else
              Relationship::OneToOne
            end

          klass.new(name, source.model, target_model, options)
        end

        # Extract the upper and lower bounds from the given cardinality
        #
        # TODO: refactor
        #
        # @param [Fixnum, Range] cardinality
        #   the cardinality to extract min/max from
        #
        # @param [Symbol, String] name
        #   the relationship name used for better error message
        #
        # @return [Array(Fixnum, Fixnum)]
        #
        # @api private
        def self.extract_min_max(cardinality, name = nil)
          case cardinality
          when Integer  then [ cardinality,       cardinality      ]
          when Range    then [ cardinality.first, cardinality.last ]
          else
            message = "must be Integer or Range but was #{cardinality.class}"

            if name
              source  = "#{self}.has(#{cardinality}, #{name.inspect}, ...)"
              message = "#{source}: #{message}"
            end

            raise ArgumentError, message
          end
        end

        private_class_method :extract_min_max

      end # class BelongsTo
    end # module Builder
  end # class Relationship
end # module DataMapper
