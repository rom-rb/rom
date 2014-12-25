module ROM
  class Header
    # @private
    class Attribute
      include Equalizer.new(:name, :key, :type)

      attr_reader :name, :key, :meta

      class Embedded < Attribute
        include Equalizer.new(:name, :type, :model, :header)

        def model
          meta[:model]
        end

        def header
          meta.fetch(:header)
        end

        def mapping
          header.mapping
        end

        def embedded?
          true
        end

        def transform?
          meta.fetch(:transform)
        end

        def to_transproc
          ops = []

          if transform?
            ops << Transproc(type == Array ? :group : :wrap, name, header.mapping.keys)
          end

          tuple_op =
            if type == Array
              Transproc(
                :map_array,
                Transproc(:map_key, key,
                          Transproc(:map_array,
                                    Transproc(:map_hash, mapping))))
            else
              Transproc(:map_array, Transproc(:map_key, key, Transproc(:map_hash, mapping)))
            end

          if model
            model_op = Transproc(-> tuple { model.new(tuple) })

            tuple_op +=
              if type == Hash
                Transproc(:map_array, Transproc(:map_key, key, model_op))
              else
                Transproc(:map_array, Transproc(:map_key, key, Transproc(:map_array, model_op)))
              end
          end

          ops << tuple_op

          ops.reduce(:+)
        end
      end

      def self.[](type)
        if type == Array || type == Hash
          Embedded
        else
          self
        end
      end

      def self.coerce(input)
        if input.is_a?(self)
          input
        else
          name = input[0]
          meta = (input[1] || {}).dup

          meta[:type] ||= Object
          meta[:transform] ||= false
          meta[:header] = Header.coerce(meta[:header]) if meta.key?(:header)

          self[meta[:type]].new(name, meta)
        end
      end

      def initialize(name, meta = {})
        @name = name
        @meta = meta
        @key = meta.fetch(:from) { name }
      end

      def type
        meta.fetch(:type)
      end

      def aliased?
        key != name
      end

      def embedded?
        false
      end

      def transform?
        false
      end

      def mapping
        [key, name]
      end
    end
  end
end
