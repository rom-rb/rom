module Rom

  # A module that adds class and instance level options
  module Options

    # Raised when the method is already used
    class ReservedMethodError < ArgumentError; end

    # Defines which options are valid for a given class
    #
    # @example
    #   class Foo
    #     accept_options :foo, :bar
    #   end
    #
    # @return [self]
    #
    # @api public
    def accept_options(*new_options)
      (new_options - accepted_options).each do |new_option|
        assert_method_available(new_option)
        add_accepted_option(new_option)
        define_option_method(new_option)
      end
      self
    end

  protected

    # Adds new option that a class can accept
    #
    # @param [Symbol] new_option
    #   new option to be added
    #
    # @return [self]
    #
    # @api private
    def add_accepted_option(new_option)
      accepted_options << new_option
      descendants.each do |descendant|
        descendant.send(__method__, new_option)
      end
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
      options.each do |option, value|
        descendant.add_accepted_option(option).public_send(option, value)
      end
    end

    # Returns default options hash for a given attribute class
    #
    # @example
    #   class Foo
    #     accept_options :foo
    #   end
    #
    #   Foo.foo = :bar
    #   Foo.options
    #   # => {:foo => :bar}
    #
    # @return [Hash]
    #   a hash of default option values
    #
    # @api private
    def options
      accepted_options.each_with_object({}) do |name, options|
        options[name] = public_send(name)
      end
    end

    # Returns an array of valid options
    #
    # @example
    #   class Foo
    #     accept_options :foo, :bar
    #   end
    #
    #   Foo.accepted_options
    #   # => [:foo, :bar]
    #
    # @return [Array]
    #   the array of valid option names
    #
    # @api private
    def accepted_options
      @accepted_options ||= []
    end

    # Assert that the option is not already defined
    #
    # @param [Symbol] name
    #
    # @return [undefined]
    #
    # @raise [ReservedMethodError]
    #   raised when the method is already defined
    #
    # @api private
    def assert_method_available(name)
      return unless respond_to?(name)
      raise ReservedMethodError,
        "method named `#{name.inspect}` is already defined"
    end

    # Adds a reader/writer method for the give option name
    #
    # @param [#to_s] name
    #
    # @return [undefined]
    #
    # @api private
    def define_option_method(name)
      ivar = "@#{name}"
      define_singleton_method(name) do |*args|
        return instance_variable_get(ivar) if args.empty?
        instance_variable_set(ivar, *args)
        self
      end
    end

  end # module Options
end # module Rom
