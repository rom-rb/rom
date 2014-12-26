require 'rom/header/attribute'

module ROM
  class Header
    class Attribute
      class Hash < Embedded

        def to_transproc
          t(:map_key, name, header.tuple_proc) if header.tuple_proc
        end

      end
    end
  end
end
