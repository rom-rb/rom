module ROM
  class Header
    class Attribute
      class Embedded < Attribute
        include Equalizer.new(:name, :type, :header)

        def t(*args)
          Transproc(*args)
        end

        def header
          meta.fetch(:header)
        end
      end
    end
  end
end
