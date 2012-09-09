require 'spec_helper'

describe DataMapper::Mapper::RelationRegistry, '#[]' do
  subject { registry['users'] }

  let(:name)     { 'users' }
  let(:relation) { mock('relation', :name => name) }
  let(:registry) { described_class.new(:users => relation) }

  it { should be(relation) }
end
