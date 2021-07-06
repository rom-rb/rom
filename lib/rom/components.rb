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
      klass.components.update(components)
    end

    # @api public
    def components
      @components ||= Registry.new(owner: self)
    end

    # TODO: move this to be part of the config object
    # @api private
    def plugins
      @plugins ||= []
    end

    # @api private
    def infer_option(option, component:)
      if component.provider && component.provider != self
        component.provider.infer_option(option, component: component)
      elsif component.option?(:constant)
        # TODO: this could be transparent so that this conditional wouldn't be needed
        component.constant.infer_option(option, component: component)
      end
    end
  end
end
