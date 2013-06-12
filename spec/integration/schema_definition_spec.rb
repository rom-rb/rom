require 'spec_helper'

shared_examples_for 'a rom schema definition' do
  specify 'registers the people relation' do
    expect(schema[:people]).to eql(people)
  end

  specify 'registers the profiles relation' do
    expect(schema[:profiles]).to eql(profiles)
  end

  specify 'registers the people_with_profile relation' do
    expect(schema[:people_with_profile]).to eql(people_with_profile)
  end
end

describe 'Defining a ROM::Schema' do

  let(:people)              { Axiom::Relation::Base.new(:people, people_header) }
  let(:people_header)       { Axiom::Relation::Header.coerce(people_attributes, :keys => people_keys) }
  let(:people_attributes)   { [ [ :id, Integer ], [ :name, String ] ] }
  let(:people_keys)         { [ :id ] }

  let(:profiles)            { Axiom::Relation::Base.new(:profiles, profiles_header) }
  let(:profiles_header)     { Axiom::Relation::Header.coerce(profiles_attributes, :keys => profiles_keys) }
  let(:profiles_attributes) { [ [ :id, Integer ], [ :person_id, Integer ], [ :text, String ] ] }
  let(:profiles_keys)       { [ [ :id ], [ :person_id ] ] }

  let(:people_with_profile) { people.join(profiles.rename(:id => :profile_id, :person_id => :id)) }

  context 'using ROM::Schema.build' do
    it_behaves_like 'a rom schema definition' do
      let(:schema) do
        ROM::Schema.build do

          base_relation :people do
            attribute :id,   Integer
            attribute :name, String

            key :id
          end

          base_relation :profiles do
            attribute :id,        Integer
            attribute :person_id, Integer
            attribute :text,      String

            key :id
            key :person_id
          end

          relation :people_with_profile do
            people.join(profiles.rename(:id => :profile_id, :person_id => :id))
          end
        end
      end
    end
  end

  context 'using ROM::Schema::Definition' do
    it_behaves_like 'a rom schema definition' do
      let(:schema) do
        definition = ROM::Schema::Definition.new

        definition.base_relation :people do
          attribute :id,   Integer
          attribute :name, String

          key :id
        end

        definition.base_relation :profiles do
          attribute :id,        Integer
          attribute :person_id, Integer
          attribute :text,      String

          key :id
          key :person_id
        end

        definition.relation :people_with_profile do
          people.join(profiles.rename(:id => :profile_id, :person_id => :id))
        end

        ROM::Schema.new(definition.relations)
      end
    end
  end
end
