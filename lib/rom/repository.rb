require 'rom/gateway'

module ROM
  # Abstract repository class
  #
  # This is a transitional placeholder, deprecating the Repository class.
  #
  # @api public
  class Repository < Gateway
    def self.inherited(_klass)
      ROM::Deprecations.announce "Inheriting from ROM::Repository is", <<-MSG
        Please inherit from ROM::Gateway instead.
      MSG
    end
  end
end
