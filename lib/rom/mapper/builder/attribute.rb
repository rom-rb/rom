# encoding: utf-8

module ROM
  class Mapper
    class Builder

      class Attribute

        include AbstractType
        include Adamantium::Flat

        module Typed
          private

          def operands
            super.unshift(type_transformer)
          end
        end

        def self.call(attribute, mappers)
          new(attribute, mappers).call
        end

        attr_reader :name
        private     :name

        attr_reader :type
        private     :type

        attr_reader :mappers
        private     :mappers

        def initialize(attribute, mappers)
          @name    = attribute.name
          @type    = attribute.type
          @mappers = mappers
        end

        def call
          Ducktrap::Node::Key::Fetch.new(fetch_operand, name)
        end

        private

        def fetch_operand
          block(operands)
        end

        def operands
          [dump]
        end

        def dump
          Ducktrap::Node::Key::Dump.new(block, name)
        end

        def block(traps = EMPTY_ARRAY)
          Ducktrap::Node::Block.new(traps)
        end
      end # class Attribute
    end # class Builder
  end # class Mapper
end # module ROM
