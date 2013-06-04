require 'spec_helper'

describe Finalizer, '#mappers' do
  subject { object.mappers }

  let(:object)  { described_class.new(ROM_ENV) }

  it { should be(ROM_ENV.mappers) }
end
