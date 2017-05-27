# Finds leaking constants created during ROM specs
module ConstantLeakFinder
  def self.find(example)
    constants = Object.constants

    example.run

    added_constants = (Object.constants - constants)
    added = added_constants.map(&Object.method(:const_get))
    if added.any? { |mod| mod.ancestors.map(&:name).grep(/\AROM/).any? }
      raise "Leaking constants: #{added_constants.inspect}"
    end
  end
end
