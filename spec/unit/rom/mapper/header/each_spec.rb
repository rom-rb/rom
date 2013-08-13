require 'spec_helper'

describe Mapper::Header, '#each' do
  let(:object)     { Mapper::Header.build(attributes) }
  let(:attributes) { [[:id, Integer], [:name, String]] }
  let(:id)         { object[:id] }
  let(:name)       { object[:name] }

  context 'with a block' do
    subject { object.each { |attribute| result << attribute } }

    let(:result) { [] }

    it { should be(object) }

    specify do
      expect { subject }.to change { result }.from([]).to([id, name])
    end
  end

  context 'without a block' do
    subject { object.each }

    it { should be_instance_of(Enumerator) }
  end
end
