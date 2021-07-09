# frozen_string_literal: true

require "dry/core/memoizable"
require "dry/core/class_builder"

require "rom/constants"
require "rom/initializer"

module ROM
  module Components
    module DSL
      # @private
      class Core
        extend Initializer
        extend Dry::Core::ClassAttributes

        defines(:key, :nested)

        include Dry::Core::Memoizable

        nested false

        # @api private
        option :provider

        # @api private
        option :gateway, default: -> { :default }

        # @api private
        option :block, optional: true

        # Specifies which DSL options map to component's settings
        #
        # @api private
        def self.settings(*keys, **mappings)
          if defined?(@settings) && (keys.empty? && mappings.empty?)
            @settings
          else
            @settings = [keys.product(keys).to_h, **mappings].reduce(:merge)
          end
        end

        # @api private
        def self.inherited(klass)
          super
          klass.instance_variable_set(:@settings, EMPTY_HASH)
        end

        # @api private
        def build_class(name: class_name, parent: class_parent, **options, &block)
          Dry::Core::ClassBuilder.new(name: name, parent: parent).call do |klass|
            klass.config.update(resolve_config)
            klass.class_exec(self, &block) if block
          end
        end

        # @api private
        def key
          self.class.key
        end

        # @api private
        def add(**options)
          components.add(key, **self.options, **options)
        end

        # @api private
        def replace(**options)
          components.replace(key, **self.options, **options)
        end

        private

        # @api private
        def resolve_config(mapping = self.class.settings)
          return {mapping => options[mapping]} if mapping.is_a?(Symbol)

          res = mapping.map { |src, trg|
            case trg
            when Hash
              {src => resolve_config(trg)}
            when Array
              {src => trg.map { |m| resolve_config(m) }.reduce(:merge)}
            when nil
              resolve_config(src => src)
            else
              {trg => options[src]} unless options[src].nil?
            end
          }

          res.compact.reduce(:merge) || EMPTY_HASH
        end

        # @api private
        def components
          provider.components
        end

        # @api private
        def inflector
          provider.inflector
        end

        # @api private
        def class_name_inferrer
          provider.class_name_inferrer
        end

        # @api private
        def provider_config
          provider.config
        end
      end
    end
  end
end
