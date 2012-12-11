require 'spec_helper'

describe Finalizer, '#mappers' do
  subject { object.mappers }

  let(:object)  { described_class.new(DM_ENV) }

  it { should be(DM_ENV.mappers) }
end
