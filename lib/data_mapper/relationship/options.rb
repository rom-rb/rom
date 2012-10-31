module DataMapper
  class Relationship

    # Relationship options
    #
    class Options

      # Name of the relationship
      #
      # @return [Symbol]
      #
      # @api private
      attr_reader :name

      # Source model for the relationship
      #
      # @return [Class]
      #
      # @api private
      attr_reader :source_model

      # Target model for the relationship
      #
      # @return [Class]
      #
      # @api private
      attr_reader :target_model

      # Source key
      #
      # @return [Symbol,nil]
      #
      # @api private
      attr_reader :source_key

      # Target key
      #
      # @return [Symbol,nil]
      #
      # @api private
      attr_reader :target_key

      # Name of the via relationship
      #
      # @return [Symbol]
      #
      # @api private
      attr_reader :via

      # Min size of the relationship children
      #
      # @return [Fixnum]
      #
      # @api private
      attr_reader :min

      # Max size of the relationship children
      #
      # @return [Fixnum]
      #
      # @api private
      attr_reader :max

      # Additional operation that must be evaluated on the relation
      #
      # @return [Proc,nil]
      #
      # @api private
      attr_reader :operation

      # Raw hash with options
      #
      # @return [Hash]
      #
      # @api private
      attr_reader :options

      # Initializes relationship options instance
      #
      # @param [String,Symbol,#to_sym] name
      # @param [Class] source model
      # @param [Class] target model
      # @param [Hash] options
      #
      # @return [undefined]
      #
      # @api private
      def initialize(name, source_model, target_model, options = {})
        @name         = name.to_sym
        @options      = options

        @source_model = source_model
        @target_model = target_model || options.fetch(:model)
        @source_key   = options[:source_key] || default_source_key
        @target_key   = options[:target_key] || default_target_key

        @via          = options[:through]
        @operation    = options[:operation]

        @min = options.fetch(min, 1)
        @max = options.fetch(max, 1)
      end

      # Return type of the options object
      #
      # @raise [NotImplementedError]
      #
      # @abstract
      #
      # @api private
      def type
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

      # Returns default name of the source key
      #
      # @return [Symbol,nil]
      #
      # @api private
      def default_source_key
        nil
      end

      # Returns default name of the target key
      #
      # @return [Symbol,nil]
      #
      # @api private
      def default_target_key
        nil
      end

      # Returns foreign key name for the given class name
      #
      # @return [Symbol]
      #
      # @api private
      #
      # TODO: this should be a class method
      def foreign_key_name(class_name)
        Inflector.foreign_key(class_name).to_sym
      end

      # Validates this options object using a specialized validator
      #
      # @raise [DataMapper::Relationship::Validator::InvalidOptionException]
      #
      # @api private
      def validate
        validator_class.new(self).validate
      end

      # Returns validator class for this options object
      #
      # @raise [NotImplementedError]
      #
      # @abstract
      #
      # @api private
      def validator_class
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end
    end # class Options
  end # class Relationship
end # module DataMapper
