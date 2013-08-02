# encoding: utf-8

require 'spec_helper'

describe Environment, '#schema' do
  let(:repositories) { Hash.new }
  let(:object)       { Environment.build(repositories) }
  let(:block)        { Proc.new {} }

  before do
    stub(Schema).build(repositories) { schema }
  end

  describe 'with a block' do
    subject { object.schema(&block) }

    fake(:schema)

    it 'calls the schema' do
      expect(subject).to be(schema)
      expect(schema).to have_received.call(&block)
    end
  end

  describe 'without a block' do
    subject { object.schema }

    fake(:schema)

    it 'calls the schema' do
      expect(subject).to be(schema)
      expect(schema).not_to have_received.call(&block)
    end
  end
end
