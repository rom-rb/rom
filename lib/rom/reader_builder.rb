require 'rom/mapper_registry'

module ROM
  # This class builds a ROM::Reader subclass for a specific relation
  #
  # It is used by the mapper DSL which invokes it when `define(:rel_name)` is
  # used.
  #
  # @private
  class ReaderBuilder
    DEFAULT_OPTIONS = { inherit_header: true }.freeze

    attr_reader :relations, :readers

    # Builds a reader instance for the provided relation
    #
    # @param [Symbol] name of the root relation
    # @param [Relation] relation that the reader will use
    # @param [MapperRegistry] registry of mappers
    # @param [Array<Symbol>] a list of method names exposed by the relation
    #
    # @return [Reader]
    #
    # @api private
    def self.build(name, relation, mappers, method_names = [])
      klass = build_class(relation, method_names)
      klass.new(name, relation, mappers)
    end

    # Build a reader subclass for the relation
    #
    # This method defines public methods on the class narrowing down data access
    # only to the methods exposed by a given relation
    #
    # @param [Relation] relation that the reader will use
    # @param [Array<Symbol>] a list of method names exposed by the relation
    #
    # @return [Class]
    #
    # @api private
    def self.build_class(relation, method_names)
      klass_name = "#{Reader.name}[#{Inflecto.camelize(relation.name)}]"

      ClassBuilder.new(name: klass_name, parent: Reader).call do |klass|
        method_names.each do |method_name|
          klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(*args, &block)
              new_relation = relation.send(#{method_name.inspect}, *args, &block)
              self.class.new(
                new_path(#{method_name.to_s.inspect}), new_relation, mappers
              )
            end
          RUBY
        end
      end
    end

    # @param [RelationRegistry]
    #
    # @api private
    def initialize(relations)
      @relations = relations
      @readers = {}
    end

    # Builds a reader instance with its mappers and stores it in readers hash
    #
    # @param [Symbol] relation name
    # @param [Hash] options for reader mappers
    #
    # @api private
    def call(name, input_options = {}, &block)
      with_options(input_options) do |options|
        parent = relations[options.fetch(:parent) { name }]

        builder = MapperBuilder.new(name, parent, options)
        builder.instance_exec(&block) if block
        mapper = builder.call

        mappers =
          if options[:parent]
            readers.fetch(parent.name).mappers
          else
            MapperRegistry.new
          end

        mappers[name] = mapper

        unless options[:parent]
          readers[name] = self.class.build(
            name, parent, mappers, parent.class.relation_methods
          )
        end
      end
    end

    private

    # @api private
    def with_options(options)
      yield(DEFAULT_OPTIONS.merge(options))
    end
  end
end
