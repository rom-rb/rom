# frozen_string_literal: true

module ROM
  # @api private
  class Transaction
    # @api private
    Rollback = Class.new(StandardError)

    # @api private
    def run(_opts = EMPTY_HASH)
      yield(self)
    rescue Rollback
      # noop
    end

    # Unconditionally roll back the current transaction
    #
    # @api public
    def rollback!
      raise Rollback
    end

    # @api private
    NoOp = Transaction.new.freeze
  end
end
