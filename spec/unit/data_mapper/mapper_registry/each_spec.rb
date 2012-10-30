require 'spec_helper'

describe MapperRegistry, '#each' do
  let(:object) { described_class.new }

  let(:model)    { mock_model('TestModel') }
  let(:relation) { mock('relation') }
  let(:mapper)   { mock_mapper(model).new(relation) }

  before { object.register(mapper) }

  context "without a block" do
    subject { object.each }

    it { should be_instance_of(Enumerator)}
  end

  context "with a block" do
    it "yields id and mapper" do
      object.each do |id, mapper|
        id.should be_instance_of(MapperRegistry::Identifier)
        mapper.should be(mapper)
      end
    end
  end
end
