# frozen_string_literal: true

require "rom/components/provider"
require "rom/components/registry"

module ROM
  # @api public
  def self.Components(*types)
    Components::Provider.new(types)
  end

  # Setup objects collect component classes during setup/finalization process
  #
  # @api public
  module Components
    # @api private
    def inherited(klass)
      super
      klass.components.update(components, abstract: true)
    end

    # @api public
    def components
      @components ||= Registry.new(owner: self)
    end

    # @api private
    def infer_option(key, type:, owner:)
      root =
        if config.respond_to?(type)
          config[type]
        else
          config.component
        end

      if root.respond_to?(key)
        value = root[key]

        if value.is_a?(Proc)
          value.(config)
        else
          value
        end
      elsif owner
        if owner.config.components[type].respond_to?(key)
          owner.config.components[type][key]
        else
          Undefined
        end
      else
        Undefined
      end
    end

    # TODO: move this to be part of the config object
    # @api private
    def plugins
      @plugins ||= []
    end
  end
end
