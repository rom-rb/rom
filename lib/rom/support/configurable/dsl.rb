# frozen_string_literal: true

require "rom/support/configurable/flags"
require "rom/support/configurable/setting"
require "rom/support/configurable/settings"
require "rom/support/configurable/compiler"

module ROM
  module Configurable
    # Setting DSL used by the class API
    #
    # @api private
    class DSL
      VALID_NAME = /\A[a-z_]\w*\z/i.freeze

      # @api private
      attr_reader :compiler

      # @api private
      attr_reader :ast

      # @api private
      def initialize(&block)
        @compiler = Compiler.new
        @ast = []
        instance_exec(&block) if block
      end

      # Registers a new setting node and compile it into a setting object
      #
      # @see ClassMethods.setting
      # @api private
      # @return Setting
      def setting(name, default = Undefined, **options, &block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        unless VALID_NAME.match?(name.to_s)
          raise ArgumentError, "#{name} is not a valid setting name"
        end

        if default != Undefined
          if ROM::Configurable.warn_on_setting_positional_default
            Dry::Core::Deprecations.announce(
              "default value as positional argument to settings",
              "Provide a `default:` keyword argument instead",
              tag: "dry-configurable",
              uplevel: 2
            )
          end

          options = options.merge(default: default)
        end

        if RUBY_VERSION < "3.0" &&
           default == Undefined &&
           (valid_opts, invalid_opts = valid_and_invalid_options(options)) &&
           invalid_opts.any? &&
           valid_opts.none?
          # In Ruby 2.6 and 2.7, when a hash is given as the second positional argument
          # (i.e. the hash is intended to be the setting's default value), and there are
          # no other keyword arguments given, the hash is assigned to the `options`
          # variable instead of `default`.
          #
          # For example, for this setting:
          #
          #   setting :hash_setting, {my_hash: true}
          #
          # We'll have a `default` of `Undefined` and an `options` of `{my_hash: true}`
          #
          # If any additional keyword arguments are provided, e.g.:
          #
          #   setting :hash_setting, {my_hash: true}, reader: true
          #
          # Then we'll have a `default` of `{my_hash: true}` and an `options` of `{reader:
          # true}`, which is what we want.
          #
          # To work around that first case and ensure our (deprecated) backwards
          # compatibility holds for Ruby 2.6 and 2.7, we extract all invalid options from
          # `options`, and if there are no remaining valid options (i.e. if there were no
          # keyword arguments given), then we can infer the invalid options to be a
          # default hash value for the setting.
          #
          # This approach also preserves the behavior of raising an ArgumentError when a
          # distinct hash is _not_ intentionally provided as the second positional
          # argument (i.e. it's not enclosed in braces), and instead invalid keyword
          # arguments are given alongside valid ones. So this setting:
          #
          #   setting :some_setting, invalid_option: true, reader: true
          #
          # Would raise an ArgumentError as expected.
          #
          # However, the one case we can't catch here is when invalid options are supplied
          # without hash literal braces, but there are no other keyword arguments
          # supplied. In this case, a setting like:
          #
          #   setting :hash_setting, my_hash: true
          #
          # Is parsed identically to the first case described above:
          #
          #   setting :hash_setting, {my_hash: true}
          #
          # So in both of these cases, the default value will become `{my_hash: true}`. We
          # consider this unlikely to be a problem in practice, since users are not likely
          # to be providing invalid options to `setting` and expecting them to be ignored.
          # Additionally, the deprecation messages will make the new behavior obvious, and
          # encourage the users to upgrade their setting definitions.

          if ROM::Configurable.warn_on_setting_positional_default
            Dry::Core::Deprecations.announce(
              "default value as positional argument to settings",
              "Provide a `default:` keyword argument instead",
              tag: "dry-configurable",
              uplevel: 2
            )
          end

          options = {default: invalid_opts}
        end

        if block && !block.arity.zero?
          if ROM::Configurable.warn_on_setting_constructor_block
            Dry::Core::Deprecations.announce(
              "passing a constructor as a block",
              "Provide a `constructor:` keyword argument instead",
              tag: "dry-configurable",
              uplevel: 2
            )
          end

          options = options.merge(constructor: block)
          block = nil
        end

        ensure_valid_options(options)

        node = [:setting, [name.to_sym, options]]

        if block
          ast << [:nested, [node, DSL.new(&block).ast]]
        else
          ast << node
        end

        compiler.visit(ast.last)
      end

      private

      def ensure_valid_options(options)
        return if options.none?

        invalid_keys = options.keys - Setting::OPTIONS

        raise ArgumentError, "Invalid options: #{invalid_keys.inspect}" unless invalid_keys.empty?
      end

      # Returns a tuple of valid and invalid options hashes derived from the options hash
      # given to the setting
      def valid_and_invalid_options(options)
        options.partition { |k, _| Setting::OPTIONS.include?(k) }.map(&:to_h)
      end
    end
  end
end
