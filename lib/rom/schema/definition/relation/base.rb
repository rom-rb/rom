# encoding: utf-8

require 'rom/schema/definition/relation'

module ROM
  class Schema
    class Definition
      class Relation

        # Base relation builder object
        #
        class Base < self

          def repository(name = Undefined)
            if name == Undefined
              @repository
            else
              @repository = name
            end
          end

        end # Base

      end # Relation
    end # Definition
  end # Schema
end # ROM
