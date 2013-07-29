# encoding: utf-8

class TestMapper < Struct.new(:header, :model)
  def load(tuple)
    model.new(
      Hash[
        header.map { |attribute| [attribute.name, tuple[attribute.name]] }
      ]
    )
  end

  def dump(object)
    header.each_with_object([]) { |attribute, tuple|
      tuple << object.send(attribute.name)
    }
  end
end
