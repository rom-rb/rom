# encoding: utf-8

require 'spec_helper'

describe Relation, '#update' do
  include_context 'Relation'

  subject { relation.update(john, old_tuple) }

  let!(:old_tuple) { relation.mapper.dump(john) }

  it { should be_instance_of(Relation) }

  before do
    john.name = 'John Doe'
  end

  it 'replaces old object with the new one' do
    expect(subject.restrict(name: 'John Doe').one).to eq(john)
  end

  it 'removes old object' do
    expect(subject.restrict(name: 'John').count).to be(0)
  end
end
