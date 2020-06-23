# frozen_string_literal: true

require "rom/associations/definitions/abstract"

module ROM
  module Associations
    module Definitions
      # @api private
      class OneToMany < Abstract
        result :many
      end
    end
  end
end
