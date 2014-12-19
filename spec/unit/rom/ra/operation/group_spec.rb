require 'spec_helper'

describe 'Group operation' do
  subject(:group) { relation.group(options) }

  let(:relation) do
    ROM::Relation.new(dataset, header).extend(ROM::RA)
  end

  let(:header) do
    [:name, :email, :street, :zipcode, :city]
  end

  let(:options) do
    { addresses: [:street, :zipcode, :city] }
  end

  context 'when group values are present' do
    let(:dataset) do
      [{ name: 'Jane',
         email: 'jane@doe.org',
         street: 'Street 1',
         zipcode: '1234',
         city: 'Cracow' }]
    end

    it 'groups given attributes under specified key' do
      expect(group.to_a).to eql(
        [{ name: 'Jane',
           email: 'jane@doe.org',
           addresses: [{ street: 'Street 1', zipcode: '1234', city: 'Cracow' }] }]
      )
    end

    it 'exposes the header' do
      expect(group.header).to eql([:name, :email, :addresses])
    end
  end

  context 'when group values are not present' do
    let(:dataset) do
      [{ name: 'Jane',
         email: 'jane@doe.org',
         street: nil,
         zipcode: nil,
         city: nil }]
    end

    it 'sets empty array for grouped attributes' do
      expect(group.to_a).to eql(
        [{ name: 'Jane', email: 'jane@doe.org', addresses: [] }]
      )
    end
  end
end
