# frozen_string_literal: true

require "rom/schema"
require "rom/attribute"

require_relative "core"

module ROM
  module Components
    module DSL
      # @private
      class Schema < Core
        key :schemas

        option :attributes, default: -> { EMPTY_HASH.dup }

        # Defines a relation attribute with its type and options.
        #
        # When only options are given, type is left as nil. It makes
        # sense when it is used alongside a schema inferrer, which will
        # populate the type.
        #
        # @see Components::DSL#schema
        #
        # @api public
        def attribute(name, type_or_options, options = EMPTY_HASH)
          if attributes.key?(name)
            raise(AttributeAlreadyDefinedError, "Attribute #{name.inspect} already defined")
          end

          build_attribute_info(name, type_or_options, options).tap do |attr_info|
            attributes[name] = attr_info
          end
        end

        # Specify which key(s) should be the primary key
        #
        # @api public
        def primary_key(*names)
          names.each do |name|
            attributes[name][:type] = attributes[name][:type].meta(primary_key: true)
          end
          self
        end

        # @api private
        def call
          # Evaluate block only if it's not a schema defined by Relation.view DSL
          instance_eval(&block) if block && !config.view

          enabled_plugins.each_value do |plugin|
            plugin.apply unless plugin.applied?
          end

          configure

          components.add(key, config: config, block: config.view ? block : nil)
        end

        # @api private
        # rubocop:disable Metrics/AbcSize
        def configure
          config.update(attributes: attributes.values)

          # TODO: make this simpler
          config.update(
            relation: relation_id,
            inferrer: config.inferrer.with(enabled: config.infer)
          )

          if !view? && relation?
            config.join!({namespace: relation_id}, :right) if config.id != relation_id

            provider.config.component.update(dataset: config.dataset) if config.dataset
            provider.config.component.update(id: config.as) if config.as
          end

          provider.config.schema.infer = config.infer

          super
        end
        # rubocop:enable Metrics/AbcSize

        private

        # Builds a representation of the information needed to create an
        # attribute. It returns a hash with `:type` and `:options` keys.
        #
        # @return [Hash]
        #
        # @see [Schema.build_attribute_info]
        #
        # @api private
        def build_attribute_info(name, type_or_options, options = EMPTY_HASH)
          type, options = if type_or_options.is_a?(::Hash)
                            [nil, type_or_options]
                          else
                            [build_type(type_or_options, options), options]
                          end
          ROM::Schema.build_attribute_info(type, **options, name: name)
        end

        # Builds a type instance from base type and meta options
        #
        # @return [Dry::Types::Type] Type instance
        #
        # @api private
        def build_type(type, options = EMPTY_HASH)
          meta = ROM::Attribute::META_OPTIONS
            .map { |opt| [opt, options[opt]] if options.key?(opt) }
            .compact
            .to_h

          # TODO: this should be probably moved to rom/compat
          source = ROM::Relation::Name[relation_id, config.dataset]

          base =
            if options[:read]
              type.meta(source: source, read: options[:read])
            elsif type.optional? && type.meta[:read]
              type.meta(source: source, read: type.meta[:read].optional)
            else
              type.meta(source: source)
            end

          if meta.empty?
            base
          else
            base.meta(meta)
          end
        end

        # @api private
        def relation_id
          relation? ? provider.config.component.id : config.id
        end

        # @api private
        def relation?
          provider.config.component.type == :relation
        end

        # @api private
        def view?
          config.view.equal?(true)
        end
      end
    end
  end
end
