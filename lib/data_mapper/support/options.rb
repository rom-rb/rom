module DataMapper

  # A module that adds class and instance level options module Options
  module Options

    # Returns default options hash for a given attribute class
    #
    # @example
    #   DataMapper::Relation::Mapper.options
    #   # => { :relation_name => :people }
    #
    # @return [Hash]
    #   a hash of default option values
    #
    # @api public
    def options
      accepted_options.each_with_object({}) do |name, options|
        ivar = "@#{name}"
        next unless instance_variable_defined?(ivar)
        options[name] = instance_variable_get(ivar)
      end
    end

    # Returns an array of valid options
    #
    # @example
    #   DataMapper::Relation::Mapper.accepted_options
    #   # => [:model, :relation_name, :repository]
    #
    # @return [Array]
    #   the array of valid option names
    #
    # @api public
    def accepted_options
      @accepted_options ||= []
    end

    # Defines which options are valid for a given attribute class
    #
    # @example
    #   class DataMapper::Relation::Mapper
    #     accept_options :relation_name, :repository
    #   end
    #
    # @return [self]
    #
    # @api public
    def accept_options(*new_options)
      add_accepted_options(new_options)
      new_options.each { |option| define_option_method(option) }
      descendants.each { |descendant| descendant.add_accepted_options(new_options) }
      self
    end

  protected

    # Sets default options
    #
    # @param [#each] new_options
    #   options to be set
    #
    # @return [self]
    #
    # @api private
    def set_options(new_options)
      new_options.each { |pair| public_send(*pair) }
      self
    end

    # Adds new options that an attribute class can accept
    #
    # @param [#to_ary] new_options
    #   new options to be added
    #
    # @return [self]
    #
    # @api private
    def add_accepted_options(new_options)
      accepted_options.concat(new_options)
      self
    end

  private

    # Adds descendant to descendants array and inherits default options
    #
    # @param [Class] descendant
    #
    # @return [undefined]
    #
    # @api private
    def inherited(descendant)
      super
      descendant.add_accepted_options(accepted_options).set_options(options)
    end

    # Adds a reader/writer method for the give option name
    #
    # @param [#to_s] option
    #
    # @return [undefined]
    #
    # @api private
    def define_option_method(option)
      ivar = "@#{option}"
      define_singleton_method(option) do |*args|
        return instance_variable_get(ivar) if args.empty?
        instance_variable_set(ivar, *args)
        self
      end
    end

  end # module Options
end # module DataMapper
