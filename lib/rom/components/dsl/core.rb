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

        defines(:nested)

        include Dry::Core::Memoizable

        nested false

        # @api private
        option :provider

        # @api private
        option :gateway, default: -> { :default }

        # @api private
        option :block, optional: true

        # @api private
        def self.config(*options, **mappings)
          if defined?(@config) && (options.empty? && mappings.empty?)
            @config
          else
            @config = [options.product(options).to_h, **mappings].reduce(:merge)
          end
        end

        # @api private
        def self.inherited(klass)
          super
          klass.instance_variable_set(:@config, EMPTY_HASH)
        end

        # @api private
        def build_class(name: class_name, parent: class_parent, **options, &block)
          Dry::Core::ClassBuilder.new(name: name, parent: parent).call do |klass|
            klass.config.update(component_options)
            klass.class_exec(self, &block) if block
          end
        end

        private

        # @api private
        def component_options(mapping = self.class.config)
          return {mapping => options[mapping]} if mapping.is_a?(Symbol)

          res = mapping.map { |src, trg|
            case trg
            when Hash
              {src => component_options(trg)}
            when Array
              {src => trg.map { |m| component_options(m) }.reduce(:merge)}
            when nil
              component_options(src => src)
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
        def config
          provider.config
        end
      end
    end
  end
end
