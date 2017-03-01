require 'rom'
require 'rom/memory'

RSpec.describe ROM::Plugins::Relation::Instrumentation do
  subject(:relation) do
    relation_class.new(dataset, notifications: notifications)
  end

  let(:dataset) do
    double(:dataset)
  end

  let(:relation_class) do
    Class.new(ROM::Memory::Relation) do
      schema(:users) do
        attribute :name, ROM::Types::String
      end

      use :instrumentation
    end
  end

  let(:notifications) { spy(:notifications) }

  it 'uses notifications API when materializing a relation' do
    relation.to_a

    expect(notifications).to have_received(:instrument).with(:memory, name: :users)
  end
end
