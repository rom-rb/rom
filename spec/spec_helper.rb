# encoding: utf-8

# SimpleCov MUST be started before require 'rom-mapper'
#
if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'spec:unit'

    add_filter 'config'
    add_filter 'lib/rom/support'
    add_filter 'spec'

    add_group 'Finalizer',    'lib/rom/finalizer'
    add_group 'Mapper',       'lib/rom/mapper'
    add_group 'Relation',     'lib/rom/relation'
    add_group 'Relationship', 'lib/rom/relationship'
    add_group 'Attribute',    'lib/rom/attribute'

    #minimum_coverage 98.10  # 0.10 lower under JRuby
  end

end

require 'shared_helper' # requires ROM

include ROM

class TestMapper < Struct.new(:header, :model)
  def load(tuple)
    model.new(
      Hash[
        header.map { |attribute| [ attribute.name, tuple[attribute.name]] }
      ]
    )
  end

  def dump(object)
    header.each_with_object([]) { |attribute, tuple|
      tuple << object.send(attribute.name)
    }
  end
end
