require 'rom/header/attribute'

module ROM
  class Header
    class Attribute
      class Array < Embedded

        def to_transproc
          t(:map_key, name, t(:map_array, header.tuple_proc)) if header.tuple_proc
        end

      end
    end
  end
end
