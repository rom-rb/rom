# encoding: utf-8

require 'spec_helper'

describe 'Defining a ROM schema' do
  let(:people) {
    Axiom::Relation::Base.new(:people, people_header)
  }

  let(:people_header) {
    Axiom::Relation::Header.coerce(people_attributes, keys: people_keys)
  }

  let(:people_attributes) {
    [[:id, Integer], [:name, String]]
  }

  let(:people_keys) {
    [:id]
  }

  let(:profiles) {
    Axiom::Relation::Base.new(:profiles, profiles_header)
  }

  let(:profiles_header) {
    Axiom::Relation::Header.coerce(profiles_attributes, keys: profiles_keys)
  }

  let(:profiles_attributes) {
    [[:id, Integer], [:person_id, Integer], [:text, String]]
  }

  let(:profiles_keys) {
    [:id, :person_id]
  }

  let(:people_with_profile) {
    people.join(profiles.rename(id: :profile_id, person_id: :id))
  }

  let(:env)        { Environment.setup(test: 'memory://test') }
  let(:repository) { env.repository(:test) }

  let(:schema) do
    env.schema do
      base_relation :people do
        repository :test

        attribute :id,   Integer
        attribute :name, String

        key :id
      end

      base_relation :profiles do
        repository :test

        attribute :id,        Integer
        attribute :person_id, Integer
        attribute :text,      String

        key :id
        key :person_id
      end
    end

    env.schema do
      relation :people_with_profile do
        people.join(profiles.rename(id: :profile_id, person_id: :id))
      end
    end
  end

  it 'registers the people relation' do
    expect(schema[:people]).to eq(people)
  end

  it 'establishes key attributes for people relation' do
    expect(schema[:people].header.keys).to include(*people_keys)
  end

  it 'establishes key attributes for profiles relation' do
    expect(schema[:profiles].header.keys).to include(*profiles_keys)
  end

  it 'registers the profiles relation' do
    expect(schema[:profiles]).to eq(profiles)
  end

  it 'registers the people_with_profile relation' do
    expect(schema[:people_with_profile]).to eq(people_with_profile)
  end
end
