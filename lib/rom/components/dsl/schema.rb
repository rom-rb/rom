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
            attr_index[name][:type] = attr_index[name][:type].meta(primary_key: true)
          end
          self
        end

        # @api private
        def call
          # Enable available plugin's
          plugins.each do |plugin|
            plugin.enable(self) unless plugin.enabled?
          end

          instance_eval(&block) if block

          # Apply plugin defaults
          plugins.each do |plugin|
            plugin.apply_to(self) unless plugin.applied?
          end

          configure

          components.add(key, config: config)
        end

        # @api private
        def configure
          config.update(attributes: attributes.values)
          super
        end

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

          base =
            if options[:read]
              type.meta(source: relation, read: options[:read])
            elsif type.optional? && type.meta[:read]
              type.meta(source: relation, read: type.meta[:read].optional)
            else
              type.meta(source: relation)
            end

          if meta.empty?
            base
          else
            base.meta(meta)
          end
        end
      end
    end
  end
end
