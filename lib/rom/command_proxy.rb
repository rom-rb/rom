# frozen_string_literal: true

require "rom/support/inflector"

module ROM
  # TODO: look into making command graphs work without the root key in the input
  #       so that we can get rid of this wrapper
  #
  # @api private
  class CommandProxy
    attr_reader :command

    attr_reader :root

    # @api private
    def initialize(command, root)
      @command = command
      @root = root
    end

    # @api private
    def call(input)
      command.call(root => input)
    end

    # @api private
    def >>(other)
      self.class.new(command >> other, root)
    end

    # @api private
    def restrictible?
      command.restrictible?
    end
  end
end
