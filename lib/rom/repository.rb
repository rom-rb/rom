require 'rom/gateway'

module ROM
  # Abstract repository class
  #
  # This is a transitional placeholder, deprecating the Repository class.
  #
  # @api public
  class Repository < Gateway
    def self.inherited(_klass)
      warn <<-MSG.gsub(/^\s+/, '')
        Inheriting from ROM::Repository is deprecated and will be removed in 1.0.0.
        Please inherit from ROM::Gateway instead.

        #{caller.detect { |l| !l.include?('lib/rom') }}
      MSG
    end
  end
end
