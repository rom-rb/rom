require 'spec_helper'
require 'data_mapper/engine/arel'

describe Engine::Arel::Gateway, '#initialize' do
  subject { described_class.new(name, relation, header) }

  let(:name)     { 'users' }
  let(:relation) { mock('relation') }
  let(:header)   { mock('header') }

  its(:relation) { should be(relation) }
  its(:name)     { should be(:users) }
  its(:header)   { should be(header) }
end
