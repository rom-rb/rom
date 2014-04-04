# encoding: utf-8

require 'spec_helper'

describe Environment::Builder, '#schema' do
  let(:repositories) { Hash.new }
  let(:object)       { Environment::Builder.call(test: "memory://test") }
  let(:block)        { -> { } }

  fake(:builder) { Schema::Builder }

  before do
    fake_class(Schema::Builder, build: -> { builder })
  end

  describe 'with a block' do
    subject { object.schema(&block) }

    it 'calls the schema' do
      expect(subject).to be(builder)
      expect(builder).to have_received.call
    end
  end

  describe 'without a block' do
    subject { object.schema }

    it 'calls the schema' do
      expect(subject).to be(builder)
      expect(builder).not_to have_received.call
    end
  end
end
