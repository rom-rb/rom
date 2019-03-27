# frozen_string_literal: true

require 'rom/support/inflector'

module ROM
  # TODO: look into making command graphs work without the root key in the input
  #       so that we can get rid of this wrapper
  #
  # @api private
  class CommandProxy
    attr_reader :command, :root

    # @api private
    def initialize(command, root = Inflector.singularize(command.name.relation).to_sym)
      @command = command
      @root = root
    end

    # @api private
    def call(input)
      command.call(root => input)
    end

    # @api private
    def >>(other)
      self.class.new(command >> other)
    end

    # @api private
    def restrictible?
      command.restrictible?
    end
  end
end
