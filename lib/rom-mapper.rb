# encoding: utf-8

require 'concord'
require 'anima'
require 'ducktrap'

module ROM

  Undefined = Class.new.freeze

  EMPTY_ARRAY = [].freeze

end

require 'rom/mapper/mapping/attribute'
require 'rom/mapper/mapping/registry'
require 'rom/mapper/mapping'
require 'rom/mapper/builder/attribute'
require 'rom/mapper/builder/attribute/simple'
require 'rom/mapper/builder/attribute/embedded'
require 'rom/mapper/builder'
require 'rom/mapper/registry'
require 'rom/mapper'
