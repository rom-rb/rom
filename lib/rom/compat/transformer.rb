# frozen_string_literal: true

require "rom/transformer"

module ROM
  Transformer.class_eval do
    class << self
      prepend SettingProxy

      # Configure relation for the transformer
      #
      # @example with a custom name
      #   class UsersMapper < ROM::Transformer
      #     relation :users, as: :json_serializer
      #
      #     map do
      #       rename_keys user_id: :id
      #       deep_stringify_keys
      #     end
      #   end
      #
      #   users.map_with(:json_serializer)
      #
      # @param name [Symbol]
      # @param options [Hash]
      # @option options :as [Symbol] Mapper identifier
      #
      # @deprecated
      #
      # @api public
      def relation(name = Undefined, as: name)
        if name == Undefined
          config.component.relation
        else
          config.component.relation = name
          config.component.namespace = name
          config.component.id = as
        end
      end

      def setting_mapping
        @setting_mapping ||= {
          register_as: [:component, :id],
          relation: [:component, [:id, :relation, :namespace]]
        }.freeze
      end
    end
  end
end
