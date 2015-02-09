module ROM
  # Abstract repository class
  #
  # @api public
  class Repository
    # Return connection object
    #
    # @return [Object] type varies depending on the repository
    #
    # @api public
    attr_reader :connection

    # @api public
    def self.setup(repository_or_scheme, *args)
      case repository_or_scheme
      when String
        raise ArgumentError, <<-STRING.gsub(/^ {10}/, '')
          URIs without an explicit scheme are not supported anymore.
          See https://github.com/rom-rb/rom/blob/master/CHANGELOG.md
        STRING
      when Symbol
        class_from_symbol(repository_or_scheme).new(*args)
      else
        if args.empty?
          repository_or_scheme
        else
          raise ArgumentError, "Can't accept arguments when passing an instance"
        end
      end
    end

    # @api private
    def self.class_from_symbol(type)
      begin
        require "rom/#{type}"
      rescue LoadError
        raise AdapterLoadError, "Failed to load adapter rom/#{type}"
      end

      adapter = ROM.adapters.fetch(type)
      adapter.const_get(:Repository)
    end

    # @api public
    def use_logger(*)
      # noop
    end

    # @api public
    def logger
      # noop
    end

    # Extension hook for adding repository-specific behavior to a command class
    #
    # @param [Class] command class
    # @param [Object] dataset
    #
    # @return [Class]
    #
    # @api public
    def extend_command_class(klass, _dataset)
      klass
    end

    # Schema inference hook
    #
    # Every repository that supports schema inference should implement this method
    #
    # @return [Array] array with datasets and their names
    #
    # @api private
    def schema
      []
    end

    # Disconnect is optional and it's a no-op by default
    #
    # @api public
    def disconnect
      # noop
    end
  end
end
