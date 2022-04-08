# frozen_string_literal: true

require "rom/container"
require "rom/global"

module ROM
  # @api private
  # @deprecated
  alias_method :plugin_registry, :plugins

  # @api public
  module Global
    # @api public
    # @deprecated
    alias_method :container, :setup
  end
end
