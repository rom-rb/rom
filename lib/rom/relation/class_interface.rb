# frozen_string_literal: true

require "set"

require "dry/effects"

require "rom/support/inflector"
require "rom/support/notifications"

require "rom/constants"
require "rom/relation/name"
require "rom/schema"

module ROM
  class Relation
    # Global class-level API for relation classes
    #
    # @api public
    module ClassInterface
      include Plugins::ClassMethods
      extend Notifications::Listener

      # Return adapter-specific relation subclass
      #
      # @example
      #   ROM::Relation[:memory]
      #   # => ROM::Memory::Relation
      #
      # @return [Class]
      #
      # @api public
      def [](adapter)
        ROM.adapters.fetch(adapter).const_get(:Relation)
      rescue KeyError
        raise AdapterNotPresentError.new(adapter, :relation)
      end

      # Dynamically define a method that will forward to the dataset and wrap
      # response in the relation itself
      #
      # @example
      #   class SomeAdapterRelation < ROM::Relation
      #     forward :super_query
      #   end
      #
      # @api public
      def forward(*methods)
        methods.each do |method|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method}(*args, &block)
              new(dataset.__send__(:#{method}, *args, &block))
            end
          RUBY
        end
      end

      # @api private
      def curried
        Curried
      end
    end
  end
end
