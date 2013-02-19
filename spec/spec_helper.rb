require 'shared_helper'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
    add_group "Finalizer",    "lib/data_mapper/finalizer"
    add_group "Mapper",       "lib/data_mapper/mapper"
    add_group "Relation",     "lib/data_mapper/relation"
    add_group "Relationship", "lib/data_mapper/relationship"
    add_group "Engine",       "lib/data_mapper/engine"
  end
end
