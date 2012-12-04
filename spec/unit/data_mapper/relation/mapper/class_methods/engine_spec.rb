require 'spec_helper'

describe Relation::Mapper, '.engine' do
  subject { object.engine }

  let(:object) { Class.new(described_class).repository(name) }
  let(:name)   { :test }

  it { should be(DataMapper.engines[name]) }
end
