require 'spec_helper'

describe 'Processor / Transproc' do
  it 'builds a transproc function from the header' do
    header = ROM::Header.coerce([[:name]])
    func = ROM::Processor::Transproc.build(header)

    relation = [{ name: 'Jane' }]

    expect(func[relation]).to eql(relation)
  end
end
