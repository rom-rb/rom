require 'spec_helper'

describe Mapper::Header, '#keys' do
  subject { object.keys }

  let(:object)  { Mapper::Header.build(attributes, options) }
  let(:id)      { object[:id] }
  let(:name)    { object[:name] }

  context 'without mapping' do
    let(:options)    { Hash[keys: [:id]] }
    let(:attributes) { [[:id, Integer], [:name, String]] }

    it { should eql([id]) }
  end

  context 'with mapping' do
    let(:attributes) { [[:user_id, Integer], [:name, String]] }
    let(:options)    { Hash[keys: [:user_id], map: { user_id: :id }] }

    it { should eql([id]) }
  end

  context 'with multiple keys' do
    let(:attributes) { [[:id, Integer], [:name, String]] }
    let(:options)    { Hash[keys: [:id, :name]] }

    it { should eql([id, name]) }
  end
end
