module ROM

  module Proxy

    def self.included(descendant)
      descendant.send :undef_method, *descendant.superclass.public_instance_methods(false).map(&:to_s)
      descendant.extend(Constructor)
      super
    end

    module Constructor

      def new(*args)
        proxy = super(*args)
        decorated_object = args.first
        proxy.instance_variable_set '@__decorated_class', decorated_object.class
        proxy.instance_variable_set '@__decorated_object', decorated_object
        proxy.instance_variable_set '@__args', args[1..args.size]
        proxy
      end

    end

    private

    def method_missing(method, *args, &block)
      forwardable?(method) ? forward(method, *args, &block) : super
    end

    def forwardable?(method)
      @__decorated_object.respond_to?(method)
    end

    def forward(*args, &block)
      response = @__decorated_object.public_send(*args, &block)

      if response.equal?(@__decorated_object)
        self
      elsif response.kind_of?(@__decorated_class)
        self.class.new(response, *@__args)
      else
        response
      end
    end

  end # Proxy

end # ROM
