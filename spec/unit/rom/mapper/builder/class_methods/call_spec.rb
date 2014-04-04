# encoding: utf-8

require 'spec_helper'

describe Mapper::Builder, '.call' do
  let(:header)   { [[:id, Integer], [:user_name, String], [:age, Integer], [:email, String]] }
  let(:relation) { Axiom::Relation::Base.new(:users, header) }
  let(:model)    { mock_model(:id, :name, :email) }
  let(:env)      { Environment.setup(test: 'memory://test') }
  let(:schema)   { Hash[users: relation] }

  context 'when attribute mapping is used' do
    let(:mapper) { subject.mappers[:users] }

    subject do
      user_model = model

      Mapper::Builder.call(schema) do
        relation(:users) do
          model user_model

          map :id, :email
          map :name, from: :user_name
        end
      end
    end

    it 'builds rom mapper' do
      expect(mapper.header.map(&:name)).to eql([:id, :email, :name])
      expect(mapper.header.map(&:type)).to eql([Integer, String, String])
    end

    it 'sets up the model' do
      object = mapper.new_object(id: 1, name: 'Jane', email: 'jane@rom.org')
      expect(object).to be_instance_of(model)
    end
  end

  context 'when custom mapper is injected' do
    subject do
      custom_mapper = test_mapper
      Mapper::Builder.call(schema) { relation(:users) { mapper(custom_mapper) } }
    end

    let(:test_mapper) { TestMapper.new(header, model) }

    it 'sets the custom mapper' do
      expect(subject.mappers[:users]).to be(test_mapper)
    end
  end

  context 'when unknown relation name is used' do
    subject { described_class.call(schema) { not_here(1, 'a') {} } }

    it 'raises error' do
      expect { subject }.to raise_error(
        NoMethodError, /undefined method `not_here'/
      )
    end
  end
end
