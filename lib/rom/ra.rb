require 'rom/ra/operation/group'
require 'rom/ra/operation/join'

module ROM

  module RA

    def self.group(relation, options)
      Operation::Group.new(relation, options)
    end

  end

end
