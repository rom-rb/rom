require 'rom/header/attribute'

module ROM
  class Header
    class Attribute
      class Wrap < Hash

        def preprocessor
          t(:wrap, name, header.mapping.keys)
        end

      end
    end
  end
end
