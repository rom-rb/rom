require 'rom'

require 'rom/repository/base'

require 'rom/plugins/relation/key_inference'

class ROM::Relation
  def self.inherited(klass)
    super
    klass.use :key_inference if klass.respond_to?(:adapter)
  end
end
