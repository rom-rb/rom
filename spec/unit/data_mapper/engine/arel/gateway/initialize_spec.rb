require 'spec_helper'
require 'data_mapper/engine/arel'

describe Engine::Arel::Gateway, '#initialize' do
  subject { described_class.new(relation, header) }

  let(:relation) { mock('relation', :name => 'users', :columns => header) }
  let(:header)   { mock('header') }

  its(:relation) { should be(relation) }
  its(:name)     { should eql(relation.name) }
  its(:header)   { should eql(header) }
end
