# frozen_string_literal: true

require "rom/support/notifications"

require "rom/changeset/create"
require "rom/changeset/update"
require "rom/changeset/delete"

require "rom/changeset/extensions/relation"

module ROM
  module Plugins
    module Relation
      # Relation plugin which adds `Relation#changeset` method
      #
      # @api public
      module Changeset
        TYPES = {
          create: ROM::Changeset::Create,
          update: ROM::Changeset::Update,
          delete: ROM::Changeset::Delete
        }.freeze

        extend Notifications::Listener

        subscribe("configuration.relations.class.ready") do |event|
          event[:relation].include(InstanceMethods)
        end

        # Relation instance methods provided by the Changeset plugin
        #
        # @api public
        module InstanceMethods
          # Create a changeset for a relation
          #
          # @overload changeset(type, data)
          #   Create a changeset of one of predefined types
          #
          #   @example creating a record
          #     users.
          #       changeset(:create, name: 'Jane').
          #       commit
          #     # => #<ROM::Struct::User id=1 name="Jane">
          #
          #   @example updating a record
          #     users.
          #       by_pk(1).
          #       changeset(:update, name: 'Jack').
          #       commit
          #     # => #<ROM::Struct::User id=1 name="Jane">
          #
          #   @example providing data as a separate step
          #     changeset = users.changeset(:create)
          #     jack = changeset.data(name: 'Jack').commit
          #     jane = changeset.data(name: 'Jane').commit
          #
          #   @example using a command graph
          #     users.
          #       changeset(
          #         :create,
          #         name: "Jane",
          #         posts: [{ title: "Something about aliens" }]
          #       )
          #
          #   @param [Symbol] type The changeset type
          #   @param [Hash] data
          #   @return [Changeset]
          #
          # @overload changeset(changeset_class, data)
          #   @example using a custom changeset class
          #     class NewUser < ROM::Changeset::Create
          #       map do |tuple|
          #         { **tuple, name: tuple.values_at(:first_name, :last_name).join(' ') }
          #       end
          #     end
          #
          #     users.changeset(NewUser, first_name: 'John', last_name: 'Doe').commit
          #
          #   @param [Class] changeset_class A custom changeset class
          #   @return [Changeset]
          #
          # @api public
          def changeset(type, data = EMPTY_HASH)
            klass = type.is_a?(Symbol) ? TYPES.fetch(type) : type

            unless klass < ROM::Changeset
              raise ArgumentError, "+#{type.name}+ must be a Changeset descendant"
            end

            if klass < ROM::Changeset::Stateful
              klass.new(self, __data__: data)
            else
              klass.new(self)
            end
          rescue KeyError
            raise ArgumentError,
                  "+#{type.inspect}+ is not a valid changeset type. Must be one of: #{TYPES.keys.inspect}"
          end
        end
      end
    end
  end
end
