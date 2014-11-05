require 'spec_helper'

describe RA, '.wrap' do
  subject(:wrap) { RA.wrap(relation, options) }

  let(:relation) do
    Relation.new([{ name: 'Jane',
       email: 'jane@doe.org',
       street: 'Street 1',
       zipcode: '1234',
       city: 'Cracow' }], header)
  end

  let(:header) do
    [:name, :email, :street, :zipcode, :city]
  end

  let(:options) do
    { address: [:street, :zipcode, :city] }
  end

  it 'wraps given attributes under specified key' do
    expect(wrap.to_a).to eql(
      [{ name: 'Jane',
         email: 'jane@doe.org',
         address: { street: 'Street 1', zipcode: '1234', city: 'Cracow' } }]
    )
  end

  it 'exposes the header' do
    expect(wrap.header).to eql([:name, :email, :address])
  end
end
