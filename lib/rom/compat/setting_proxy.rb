# frozen_string_literal: true

require "dry/core/class_attributes"

module ROM
  module SettingProxy
    extend Dry::Core::ClassAttributes

    private

    # @api private
    def respond_to_missing?(name, include_all = false)
      super || setting_mapping.key?(name)
    end

    # Delegate to config when accessing deprecated class attributes
    #
    # @api private
    def method_missing(name, *args, &block)
      return super unless setting_mapping.key?(name)

      mapping = setting_mapping[name]
      ns, key = mapping

      if args.empty?
        if mapping.empty?
          config[name]
        else
          config[ns][Array(key).first]
        end
      else
        value = args.first

        if mapping.empty?
          config[name] = value
        else
          Array(key).each { |k| config[ns][k] = value }
        end

        value
      end
    end
  end
end
