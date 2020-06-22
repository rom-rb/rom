# frozen_string_literal: true

require 'rom/configuration'
require 'rom/environment'
require 'rom/setup'
require 'rom/setup/finalize'

module ROM
  # @api private
  class CreateContainer
    # @api private
    attr_reader :container

    # @api private
    def initialize(environment, setup)
      @container = finalize(environment, setup)
    end

    private

    # @api private
    def finalize(environment, setup)
      environment.configure do |config|
        environment.gateways.each_key do |key|
          gateway_config = config.gateways[key]
          gateway_config.infer_relations = true unless gateway_config.key?(:infer_relations)
        end
      end

      finalize = Finalize.new(
        gateways: environment.gateways,
        relation_classes: setup.relation_classes,
        command_classes: setup.command_classes,
        mappers: setup.mapper_classes,
        plugins: setup.plugins,
        notifications: setup.notifications,
        config: environment.config.dup.freeze
      )

      finalize.run!
    end
  end

  # @api private
  class InlineCreateContainer < CreateContainer
    # @api private
    def initialize(*args, &block)
      case args.first
      when Configuration
        environment = args.first.environment
        setup = args.first.setup
      when Environment
        environment = args.first
        setup = args[1]
      else
        configuration = Configuration.new(*args, &block)
        environment = configuration.environment
        setup = configuration.setup
      end

      super(environment, setup)
    end
  end

  # @api private
  def self.container(*args, &block)
    InlineCreateContainer.new(*args, &block).container
  end
end
