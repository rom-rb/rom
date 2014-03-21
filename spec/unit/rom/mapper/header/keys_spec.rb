# encoding: utf-8

require 'spec_helper'

describe Mapper::Header, '#keys' do
  subject { object.keys }

  let(:object)  { Mapper::Header.build(attributes) }
  let(:id)      { object[:id] }
  let(:name)    { object[:name] }

  context 'without mapping' do
    let(:attributes) { [[:id], [:name]] }

    it { should eql([]) }
  end

  context 'with mapping' do
    let(:attributes) { [[:id, from: :user_id, key: true], [:name]] }

    it { should eql([id]) }
  end

  context 'with multiple keys' do
    let(:attributes) { [[:id, key: true], [:name, key: true]] }

    it { should eql([id, name]) }
  end
end
