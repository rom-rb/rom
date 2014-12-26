require 'rom/header/attribute'

module ROM
  class Header
    class Attribute
      class Group < Array

        def preprocess?
          true
        end

      end
    end
  end
end
