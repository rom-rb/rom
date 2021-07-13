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

        defines(:key, :type, :nested)

        include Dry::Core::Memoizable

        nested false

        # @api private
        option :provider

        # @api private
        option :config, optional: true, default: -> { EMPTY_HASH }

        # @api private
        option :block, optional: true

        # Specifies which DSL options map to component's settings
        #
        # @api private
        def self.settings(*keys, **mappings)
          if defined?(@settings) && (keys.empty? && mappings.empty?)
            @settings
          else
            @settings = [keys.zip(keys).to_h, **mappings].reduce(:merge)
          end
        end

        # @api private
        def self.inherited(klass)
          super
          klass.instance_variable_set(:@settings, EMPTY_HASH)
          klass.type(Inflector.component_id(klass).to_sym)
        end

        # @api private
        def build_class(name: class_name, parent: class_parent, &block)
          Dry::Core::ClassBuilder.new(name: name, parent: parent).call do |klass|
            klass.config.update(component: config)

            defaults = (klass.settings & component_types)
              .map { |type|
                [
                  type,
                  merge_configs(provider.config[type], klass.config[type], fallback: klass.config)
                ]
              }
              .to_h

            klass.config.update(defaults)

            klass.class_exec(self, &block) if block
          end
        end

        # @api private
        def key
          self.class.key
        end

        # @api private
        def type
          self.class.type
        end

        # @api private
        def component_types
          %i[gateway dataset schema relation association mapper]
        end

        # @api private
        def add(config: EMPTY_HASH, **options)
          components.add(key, config: self.config.merge(config), block: block, **options)
        end

        # @api private
        memoize def config
          merge_configs(provider.config[type], _config, fallback: provider.config)
            .then { |defaults| defaults.merge(resolve_config(defaults)) }
        end

        private

        # @api private
        def merge_configs(left, right, fallback:)
          [left, right].map(&:to_h).map(&:compact).reduce(:merge).then { |defaults|
            defaults.transform_values { |value| value.is_a?(Proc) ? value.(fallback) : value }
          }
        end

        # @api private
        def resolve_config(config, mapping = self.class.settings)
          return {mapping => config[mapping]} if mapping.is_a?(Symbol)

          res = mapping.map { |src, trg|
            case trg
            when Hash
              {src => resolve_config(config, trg)}
            when Array
              {src => trg.map { |m| resolve_config(config, m) }.reduce(:merge)}
            when nil
              resolve_config(config, {src => src})
            else
              {trg => config[src]} unless config[src].nil?
            end
          }

          res.compact.reduce(:merge) || EMPTY_HASH
        end

        # @api private
        def _config
          options[:config]
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
      end
    end
  end
end
