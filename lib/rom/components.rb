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
      @components ||= Registry.new(provider: self)
    end
  end
end
