# frozen_string_literal: true

require "rom/mapper"

module ROM
  class Mapper
    class << self
      prepend SettingProxy

      def setting_mapping
        @setting_mapper ||= ROM::Transformer.setting_mapping.merge(
          inherit_header: [],
          reject_keys: [],
          symbolize_keys: [],
          copy_keys: [],
          prefix: [],
          prefix_separator: []
        ).freeze
      end
    end
  end
end
