require 'spec_helper'

describe Mapper::Relation, '.engine' do
  subject { object.engine }

  let(:object) { Class.new(described_class).repository(name) }
  let(:name)   { :test }

  it { should be(DataMapper.engines[name]) }
end
