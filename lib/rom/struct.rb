require 'anima'

require 'rom/support/class_builder'

module ROM
  class Struct
    def to_hash
      to_h
    end

    def [](name)
      instance_variable_get("@#{name}")
    end
  end
end
