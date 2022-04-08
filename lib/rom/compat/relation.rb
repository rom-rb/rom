# frozen_string_literal: true

require "rom/relation"
require_relative "schema/dsl"

module ROM
  class Relation
    class << self
      prepend SettingProxy

      def setting_mapping
        @setting_mapping ||= {
          auto_map: [],
          auto_struct: [],
          struct_namespace: [],
          wrap_class: [],
          adapter: [:component, :adapter],
          gateway: [:component, :gateway],
          schema_class: [:schema, :constant],
          schema_dsl: [:schema, :dsl_class],
          schema_attr_class: [:schema, :attr_class],
          schema_inferrer: [:schema, :inferrer]
        }.freeze
      end
    end

    # This is used by the deprecated command => relation view delegation syntax
    # @api private
    def self.view_methods
      ancestor_methods = ancestors.reject { |klass| klass == self }
        .map(&:instance_methods).flatten(1)

      instance_methods - ancestor_methods + auto_curried_methods.to_a
    end

    config.schema.dsl_class = ROM::Schema::DSL
  end
end
