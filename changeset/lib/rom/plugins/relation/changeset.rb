require 'rom/support/notifications'

require 'rom/changeset/create'
require 'rom/changeset/update'
require 'rom/changeset/delete'

module ROM
  module Plugins
    module Relation
      module Changeset
        TYPES = {
          create: ROM::Changeset::Create,
          update: ROM::Changeset::Update,
          delete: ROM::Changeset::Delete
        }.freeze

        extend Notifications::Listener

        subscribe('configuration.relations.class.ready') do |event|
          event[:relation].include(InstanceMethods)
        end

        module InstanceMethods

          # Create a changeset for a relation
          #
          # @return [Changeset]
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
