require 'rom/ra/operation/join'
require 'rom/ra/operation/group'
require 'rom/ra/operation/wrap'

module ROM

  module RA

    def self.join(*args)
      Operation::Join.new(*args)
    end

    def self.group(*args)
      Operation::Group.new(*args)
    end

    def self.wrap(*args)
      Operation::Wrap.new(*args)
    end

  end

end
