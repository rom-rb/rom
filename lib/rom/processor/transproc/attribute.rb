module ROM
  class Processor
    class Transproc < Processor
      class Attribute
        include ::Transproc::Composer
        extend Forwardable

        def_delegators :@attribute, :name, :header, :tuple_keys, :pop_keys, :type, :typed?

        # @param [Header::Attribute] attribute
        # @param [Boolean] preprocess true if we are building a relation preprocessing
        #                             function that is applied to the whole relation
        #
        # @api private
        def initialize(attribute, preprocess = false)
          @attribute = attribute
          @preprocess = preprocess
        end

        # Process an attribute from the header
        #
        # This forwards to a specialized visitor based on the attribute type
        #
        # @api private
        def to_transproc
          send("process_#{attribute_type}")
        end

        private

        # Process plain attribute
        #
        # It will call block transformation if it's used
        #
        # If it's a typed attribute a coercion transformation is added
        #
        # @api private
        def process_attribute
          t(:map_value, name, coercer) if coercer
        end

        # Process hash attribute
        #
        # @api private
        def process_hash
          with_row_proc do |row_proc|
            t(:map_value, name, row_proc)
          end
        end

        # Process combined attribute
        #
        # @api private
        def process_combined
          op = with_row_proc do |row_proc|
            array_proc =
              if type == :hash
                t(:map_array, row_proc) >> -> arr { arr.first }
              else
                t(:map_array, row_proc)
              end

            t(:map_value, name, array_proc)
          end

          if op
            op
          elsif type == :hash
            t(:map_value, name, -> arr { arr.first })
          end
        end

        # Process array attribute
        #
        # @api private
        def process_array
          with_row_proc do |row_proc|
            t(:map_value, name, t(:map_array, row_proc))
          end
        end

        # Process wrapped hash attribute
        #
        # :nest transformation is added to handle wrapping
        #
        # @api private
        def process_wrap
          compose do |ops|
            ops << t(:nest, name, tuple_keys)
            ops << process_hash
          end
        end

        # Process unwrap attribute
        #
        # :unwrap transformation is added to handle unwrapping
        #
        # @api private
        def process_unwrap
          compose do |ops|
            ops << process_hash
            ops << t(:unwrap, name, pop_keys)
          end
        end

        # Process group hash attribute
        #
        # :group transformation is added to handle grouping during preprocessing.
        # Otherwise we simply use array visitor for the attribute.
        #
        # @api private
        def process_group
          if @preprocess
            compose do |ops|
              ops << t(:group, name, tuple_keys)
              ops << t(:map_array, t(:map_value, name, FILTER_EMPTY))
              ops << process_preprocessed
            end
          else
            process_array
          end
        end

        # Process ungroup attribute
        #
        # :ungroup transforation is added to handle ungrouping during preprocessing.
        # Otherwise we simply use array visitor for the attribute.
        #
        # @api private
        def process_ungroup
          if @preprocess
            compose do |ops|
              ops << process_postprocessed
              ops << t(:ungroup, name, pop_keys)
            end
          else
            process_array
          end
        end

        # Process fold hash attribute
        #
        # :fold transformation is added to handle folding during preprocessing.
        #
        # @api private
        def process_fold
          if @preprocess
            compose do |ops|
              ops << t(:group, name, tuple_keys)
              ops << t(:map_array, t(:map_value, name, FILTER_EMPTY))
              ops << t(:map_array, t(:fold, name, tuple_keys.first))
            end
          end
        end

        # Process unfold hash attribute
        #
        # :unfold transformation is added to handle unfolding during preprocessing.
        #
        # @api private
        def process_unfold
          if @preprocess
            key = pop_keys.first
            compose do |ops|
              ops << process_postprocessed
              ops << t(:map_array, t(:map_value, name, t(:insert_key, key)))
              ops << t(:map_array, t(:reject_keys, [key] - [name]))
              ops << t(:ungroup, name, [key])
            end
          end
        end

        # Process excluded attribute
        #
        # @api private
        def process_exclude
          t(:reject_keys, [name])
        end

        def process_postprocessed
          process_others(header.postprocessed)
        end

        def process_preprocessed
          process_others(header.preprocessed)
        end

        def process_others(others)
          others.map { |attr|
            t(:map_array, t(:map_value, name, Attribute.new(attr, true).to_transproc))
          }
        end

        # Yield row proc for a given attribute if any
        #
        # @api private
        def with_row_proc
          row_proc = row_proc_from
          yield(row_proc) if row_proc
        end

        # Build a row_proc from a given attribute
        #
        # This is used by embedded attribute visitors
        #
        # @api private
        def row_proc_from
          RowsProcessor.new(header).row_proc
        end

        def coercer
          meta_coercer || type_coercer
        end

        def meta_coercer
          @attribute.meta[:coercer]
        end

        def type_coercer
          t(:"to_#{type}") if typed?
        end

        def attribute_type
          @attribute.class.name.split('::').last.downcase
        end

      end
    end
  end
end