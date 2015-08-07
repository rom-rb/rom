require 'wisper'

module ROM
  module Support
    module Publisher
      def self.included(klass)
        klass.__send__(:include, Wisper::Publisher)
      end
    end
  end
end
