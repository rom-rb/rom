RSpec.describe ROM::Changeset, '.map' do
  subject(:changeset) do
    Class.new(ROM::Changeset) do
      map do
        unwrap :address
        rename_keys street: :address_street, city: :address_city, country: :address_country
      end
    end.new(relation, data: user_data)
  end

  let(:relation) { double(:relation) }

  let(:user_data) do
    { name: 'Jane', address: { street: 'Street 1', city: 'NYC', country: 'US' } }
  end

  it 'sets up custom data pipe' do
    expect(changeset.to_h)
      .to eql(name: 'Jane', address_street: 'Street 1', address_city: 'NYC', address_country: 'US' )
  end
end
