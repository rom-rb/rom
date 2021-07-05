# frozen_string_literal: true

# register core plugins
require "rom/plugins"

# global interface
require "rom/global"

module ROM
  extend Global

  plugins do
    register :timestamps, ROM::Plugins::Schema::Timestamps, type: :schema
    register :registry_reader, ROM::Plugins::Relation::RegistryReader, type: :relation
    register :instrumentation, ROM::Plugins::Relation::Instrumentation, type: :relation
    register :schema, ROM::Plugins::Command::Schema, type: :command
    register :timestamps, ROM::Plugins::Command::Timestamps, type: :command
  end
end

require "rom/components/dsl"

module ROM
  class DSL < Module
    attr_reader :name, :configuration

    def initialize(name, configuration)
      super()
      @name = name
      @configuration = configuration
    end

    def extended(klass)
      super
      define_configuration_methods(configuration)
      define_runtime_methods(self, klass)
    end

    def define_configuration_methods(configuration)
      %i[relation commands mappers plugin].each do |meth|
        define_method(meth) do |*args, **options, &meth_block|
          configuration.__send__(meth, *args, **options, &meth_block)
        end
      end
    end

    def define_runtime_methods(dsl, klass)
      klass.define_method(dsl.name) do
        ivar = :"@#{__method__}"

        if instance_variable_defined?(ivar)
          instance_variable_get(ivar)
        else
          instance_variable_set(ivar, ::ROM.container(dsl.configuration))
        end
      end

      %i[gateways relations commands mappers].each do |meth|
        klass.define_method(meth) { __send__(dsl.name).__send__(meth) }
      end
    end
  end
end

def ROM(*args, as: :rom)
  ROM::DSL.new(as, ROM::Configuration.new(*args))
end
