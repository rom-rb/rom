require 'spec_helper'

describe Mapper, '#dump' do
  include_context 'Mapper'

  it 'dumps the object into data tuple' do
    stub(dumper).call(object) { data }

    expect(mapper.dump(object)).to be(data)

    dumper.should have_received.call(object)
  end
end
