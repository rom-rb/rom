module DataMapper
  class Mapper
    class Relationship

      class Builder
        attr_reader :name
        attr_reader :source_mapper
        attr_reader :target_model
        attr_reader :source_key
        attr_reader :target_key

        def initialize(name, source_mapper, options)
          @name          = name
          @source_mapper = source_mapper.class
          @target_model  = options[:target_model]
          @source_key    = options[:source_key] ||= default_source_key
          @target_key    = options[:target_key] ||= default_target_key
          @renamings     = options[:rename]     ||= {}
        end

        def mapper_class
          klass = remap_fields(Class.new(source_mapper))
          klass.map(name, target_model_attribute_options)
          klass.finalize_attributes
          klass
        end

        def operation
          raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
        end

        private

        def remap_fields(mapper)
          fields.each do |name, field|
            original = mapper.attributes[name]
            mapper.map(name, :type => original.type, :key => original.key?, :to => field)
          end

          mapper
        end

        def fields
          @renamings
        end

        def target_model_attribute_options
          { :type => target_model }
        end

        def foreign_key_name
          "#{@name}_id".to_sym
        end

        def default_source_key
          raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
        end

        def default_target_key
          raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
        end
      end
    end
  end
end
