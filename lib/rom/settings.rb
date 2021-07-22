# frozen_string_literal: true

require_relative "support/inflector"
require_relative "support/configurable"

module ROM
  extend Configurable

  # Defaults for all component types
  setting :component do
    setting :type
    setting :abstract, default: false
    setting :adapter
    setting :gateway, default: :default
    setting :inflector, default: Inflector
    setting :plugins, default: EMPTY_ARRAY, inherit: true
  end

  # Gateway defaults
  setting :gateway do
    setting :type, default: :gateway
    setting :id, default: :default
    setting :namespace, default: "gateways"
    setting :adapter
    setting :logger
    setting :args, default: EMPTY_ARRAY, constructor: :dup.to_proc
    setting :opts, default: EMPTY_HASH, constructor: :dup.to_proc
  end

  # Dataset defaults
  setting :dataset do
    setting :type, default: :dataset
    setting :abstract
    setting :id
    setting :namespace, default: "datasets"
    setting :adapter
    setting :gateway
  end

  # Schema defaults
  setting :schema do
    setting :type, default: :schema
    setting :id
    setting :namespace, default: "schemas", join: true
    setting :dataset
    setting :as # TODO: move to rom/compat
    setting :relation # TODO: move to rom/compat
    setting :adapter
    setting :gateway
    setting :view, default: false
    setting :infer, default: false
    setting :constant
    setting :dsl_class # TODO: move to rom/compat
    setting :attr_class
    setting :inferrer
    setting :attributes, default: EMPTY_ARRAY, constructor: :dup.to_proc
    setting :plugins, default: EMPTY_ARRAY, inherit: true
  end

  # Relation defaults
  setting :relation do
    setting :type, default: :relation
    setting :abstract
    setting :id
    setting :namespace, default: "relations"
    setting :dataset
    setting :adapter
    setting :inflector
    setting :gateway
    setting :plugins, default: EMPTY_ARRAY, inherit: true
  end

  # Association defaults
  setting :association do
    setting :type, default: :association
    setting :id
    setting :namespace, default: "associations", join: true
    setting :inflector
    setting :adapter
    setting :as
    setting :name
    setting :relation
    setting :source
    setting :target
    setting :through
    setting :foreign_key
    setting :result
    setting :view
    setting :override
    setting :combine_keys
  end

  # Command defaults
  setting :command do
    setting :type, default: :command
    setting :id
    setting :namespace, default: "commands", join: true
    setting :relation
    setting :adapter
    setting :gateway
  end

  # Command defaults
  setting :mapper do
    setting :type, default: :mapper
    setting :id
    setting :namespace, default: "mappers", join: true
    setting :relation
    setting :adapter
  end

  # @api private
  def self.settings
    _settings
  end
end
