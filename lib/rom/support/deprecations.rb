module ROM
  module Deprecations
    # @api private
    def deprecate(old_name, new_name, msg = nil)
      class_eval do
        define_method(old_name) do |*args, &block|
          warn <<-MSG.gsub(/^\s+/, '')
            #{self.class}##{old_name} is deprecated and will be removed in 1.0.0.
            Please use #{self.class}##{new_name} instead.
            #{msg}
            #{caller.detect { |l| !l.include?('lib/rom')}}
          MSG
          __send__(new_name, *args, &block)
        end
      end
    end

    def deprecate_class_method(old_name, new_name, msg = nil)
      class_eval do
        define_singleton_method(old_name) do |*args, &block|
          warn <<-MSG.gsub(/^\s+/, '')
            #{self}.#{old_name} is deprecated and will be removed in 1.0.0.
            Please use #{self}.#{new_name} instead.
            #{msg}
            #{caller.detect { |l| !l.include?('lib/rom')}}
          MSG
          __send__(new_name, *args, &block)
        end
      end
    end

  end
end
