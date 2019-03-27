# frozen_string_literal: true

require 'rom/associations/many_to_many'

module ROM
  module Associations
    # Abstract one-to-one-through association type
    #
    # @api public
    class OneToOneThrough < ManyToMany
    end
  end
end
