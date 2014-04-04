# encoding: utf-8

require 'spec_helper'

describe Mapper::Builder, '.new' do
  let(:header)   { [[:id, Integer], [:user_name, String], [:age, Integer], [:email, String]] }
  let(:relation) { Axiom::Relation::Base.new(:users, header) }
  let(:model)    { mock_model(:id, :name, :email) }
  let(:env)      { Environment.setup(test: 'memory://test') }
  let(:schema)   { Hash[users: relation] }

  context 'when attribute mapping is used' do
    subject { env }

    let(:mapper) { subject[:users].mapper }

    before do
      user_model = model

      Mapper::Builder.new(env, schema) do
        users do
          model user_model

          map :id, :email
          map :name, from: :user_name
        end
      end
    end

    it 'registers rom relation' do
      expect(subject[:users]).to be_instance_of(Relation)
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
    subject { env }

    let(:test_mapper) { TestMapper.new(header, model) }

    before do
      custom_mapper = test_mapper
      Mapper::Builder.new(env, schema) { users { mapper(custom_mapper) } }
    end

    it 'sets the custom mapper' do
      expect(subject[:users].mapper).to be(test_mapper)
    end
  end

  context 'when unknown relation name is used' do
    subject { described_class.new(env, schema) { not_here(1, 'a') {} } }

    it 'raises error' do
      expect { subject }.to raise_error(
        NoMethodError, /undefined method `not_here'/
      )
    end
  end
end
