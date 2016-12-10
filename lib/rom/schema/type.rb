require 'delegate'
require 'dry/equalizer'
require 'dry/types/decorator'

module ROM
  class Schema
    class Type < SimpleDelegator
      include Dry::Equalizer(:type)
      alias_method :type, :__getobj__
    end
  end
end
