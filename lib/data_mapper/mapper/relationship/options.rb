module DataMapper
  class Mapper
    class Relationship

      class Options

        attr_reader :name
        attr_reader :mapper_class
        attr_reader :source_model
        attr_reader :target_model
        attr_reader :source_key
        attr_reader :target_key
        attr_reader :renamings
        attr_reader :through

        attr_accessor :source
        attr_accessor :operation

        def initialize(name, source_model, target_model, options)
          @name         = name.to_sym
          @options      = options
          @source       = options[:source]
          @through      = options[:through]
          @mapper_class = options[:mapper]
          @operation    = options[:operation]

          if @mapper_class
            @source_model = @mapper_class.model
            @target_model = @mapper_class.attributes[@name].type
          else
            @source_model = source_model
            @target_model = target_model || options.delete(:model)
          end

          @source_key = options[:source_key] || default_source_key
          @target_key = options[:target_key] || default_target_key
          @renamings  = options[:rename]     || {}
        end

        def inherit(name, options)
          self.class.new(name, source_model, target_model, @options.merge(options))
        end

        def [](key)
          public_send(key)
        end

        def type
          raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
        end

        def default_source_key
          nil
        end

        def default_target_key
          nil
        end

        private

        def foreign_key_name(class_name)
          DataMapper::Inflector.foreign_key(class_name).to_sym
        end
      end # class Options
    end # class Relationship
  end # class Mapper
end # module DataMapper
