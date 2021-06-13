# frozen_string_literal: true

require "dry/effects"

require "rom/configuration"
require "rom/setup/finalize"

module ROM
  # @api private
  class CreateContainer
    include Dry::Effects::Handler.Reader(:configuration)

    # @api private
    attr_reader :container

    # @api private
    attr_reader :configuration

    # @api private
    attr_reader :notifications

    # @api private
    def initialize(configuration)
      @configuration = configuration
      @container = finalize
    end

    private

    # @api private
    def finalize
      configuration.configure do |config|
        configuration.gateways.each_key do |key|
          gateway_config = config.gateways[key]
          gateway_config.infer_relations = true unless gateway_config.key?(:infer_relations)
        end
      end

      with_configuration(configuration) do
        finalize = Finalize.new(configuration)
        finalize.run!
      end
    end
  end

  # @api private
  class InlineCreateContainer < CreateContainer
    # @api private
    def initialize(*args, &block)
      configuration =
        case args.first
        when Configuration
          configuration = args.first
        else
          configuration = Configuration.new(*args, &block)
        end

      super(configuration)
    end
  end

  # @api private
  def self.container(*args, &block)
    InlineCreateContainer.new(*args, &block).container
  end
end
