require 'spec_helper'

describe ROM, '.setup' do
  let(:jane) { { id: 1, name: 'Jane' } }
  let(:joe) { { id: 2, name: 'Joe' } }

  it 'configures relations' do
    rom = ROM.setup(sqlite: "sqlite::memory")

    seed(rom.sqlite.connection)

    expect(rom.sqlite.users.to_a).to eql([jane, joe])
  end
end
