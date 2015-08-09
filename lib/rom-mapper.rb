module ROM
  Undefined = Object.new.freeze
  EMPTY_HASH = Hash.new.freeze
  EMPTY_ARRAY = Array.new.freeze
  MapperMisconfiguredError = Class.new(StandardError)
end

require 'rom/mapper'
require 'rom/processor/transproc'
