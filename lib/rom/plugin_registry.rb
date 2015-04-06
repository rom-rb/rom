require 'rom/support/registry'

module ROM

  class PluginRegistry < Registry
    attr_reader :plugins

    def register(name, mod, options = {})
      elements[name] = Plugin.new(mod, options)
    end

  end

end
