require 'rom/header/attribute'

module ROM
  class Header
    class Attribute
      class Wrap < Hash

        def preprocess?
          true
        end

      end
    end
  end
end
