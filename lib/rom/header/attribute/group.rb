require 'rom/header/attribute'

module ROM
  class Header
    class Attribute
      class Group < Array

        def preprocessor
          t(:group, name, header.mapping.keys)
        end

      end
    end
  end
end
