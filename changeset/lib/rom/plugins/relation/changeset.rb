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
          def changeset(type, data)
            TYPES.fetch(type).new(self, __data__: data)
          end
        end
      end
    end
  end
end
