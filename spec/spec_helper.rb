# encoding: utf-8

# SimpleCov MUST be started before require 'dm-mapper'
#
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    command_name 'spec:unit'

    add_filter "spec"
    add_filter "config"
    add_filter "lib/data_mapper/support"

    add_group "Finalizer",    "lib/data_mapper/finalizer"
    add_group "Mapper",       "lib/data_mapper/mapper"
    add_group "Relation",     "lib/data_mapper/relation"
    add_group "Relationship", "lib/data_mapper/relationship"
    add_group "Attribute",    "lib/data_mapper/attribute"
  end

end

require 'shared_helper' # requires dm-mapper
