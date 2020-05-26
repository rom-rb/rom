# frozen_string_literal: true

require 'rom/associations/definitions/abstract'

module ROM
  module Associations
    module Definitions
      # @api private
      class ManyToOne < Abstract
        result :one
      end
    end
  end
end
