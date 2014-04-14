# encoding: utf-8

require 'spec_helper'

describe Environment::Builder, '#schema' do
  subject(:builder) { Environment::Builder.new({}, schema, {}) }

  fake(:schema) { Schema::Builder }

  context 'with a block' do
    let(:block) { Proc.new {} }

    it 'calls the schema' do
      stub(schema).call { schema }
      expect(builder.schema(&block)).to be(schema)
      expect(schema).to have_received.call(&block)
    end
  end

  context 'without a block' do
    it 'returns the schema' do
      expect(builder.schema).to be(schema)
      expect(schema).not_to have_received.call
    end
  end
end
