# encoding: utf-8

module ROM
  class Mapper
    class Builder

      include Adamantium::Flat

      def self.call(registry, mapping)
        new(registry, mapping).call
      end

      def initialize(registry, mapping)
        @registry = registry
        @model    = mapping.model
        @header   = mapping.header
      end

      def call
        Ducktrap::Node::Block.new([transform, anima_load])
      end

      private

      def transform
        Ducktrap::Node::Hash::Transform.new(attribute_transformers)
      end

      def attribute_transformers
        @header.map { |attribute| attribute.transformer(@registry) }
      end

      def anima_load
        Ducktrap::Node::Anima::Load.new(@model)
      end
    end # class Builder
  end # class Mapper
end # module ROM
