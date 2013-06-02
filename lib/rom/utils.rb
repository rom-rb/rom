module Rom

  module Utils

    # @api private
    def self.extract_type(args)
      type = args.first
      return if type.is_a?(Hash)
      type
    end

    # @api private
    def self.extract_options(args)
      options = args.last
      options.respond_to?(:to_hash) ? options.to_hash.dup : {}
    end
  end # module Utils
end # module Rom
