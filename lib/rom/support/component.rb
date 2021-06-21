# frozen_string_literal: true

require_relative "inflector"

module ROM
  module Component
    # @api private
    def id
      @id ||= (register_as || relation || infer_id)
    end

    # @api private
    def infer_id
      Inflector.underscore(Inflector.demodulize(name)).to_sym
    end
  end
end
