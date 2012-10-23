module DataMapper
  class Relationship

    class Options

      attr_reader :name
      attr_reader :source_model
      attr_reader :target_model
      attr_reader :source_key
      attr_reader :target_key
      attr_reader :via
      attr_reader :min
      attr_reader :max
      attr_reader :operation
      attr_reader :options

      def initialize(name, source_model, target_model, options = {})
        @name         = name.to_sym
        @options      = options
        @via          = options[:through]
        @operation    = options[:operation]
        @source_model = source_model
        @target_model = target_model || options.fetch(:model)
        @source_key   = options[:source_key] || default_source_key
        @target_key   = options[:target_key] || default_target_key

        @min = options.fetch(min, 1)
        @max = options.fetch(max, 1)
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

      def validate
        validator_class.new(self).validate
      end

      def foreign_key_name(class_name)
        Inflector.foreign_key(class_name).to_sym
      end

      # @api private
      def validator_class
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end
    end # class Options
  end # class Relationship
end # module DataMapper
