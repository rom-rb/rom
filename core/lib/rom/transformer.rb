require 'dry/core/class_attributes'
require 'transproc/transformer'

require 'rom/processor/transproc'

module ROM
  # Transformer is a data mapper which uses Transproc's transformer DSL to define
  # transformations.
  #
  # @api public
  class Transformer < Transproc::Transformer[ROM::Processor::Transproc::Functions]
    extend Dry::Core::ClassAttributes

    defines :relation, :register_as

    # This is needed to make transformers compatible with rom setup
    #
    # @api private
    def self.base_relation
      relation
    end

    # Build a mapper instance
    #
    # @return [Transformer]
    #
    # @api public
    def self.build
      new
    end
  end
end
