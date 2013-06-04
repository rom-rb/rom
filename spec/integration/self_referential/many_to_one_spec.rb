require 'spec_helper_integration'

describe 'Relationship - Self referential Many To One' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_person 1, 'John'
    insert_person 2, 'Jane', 1

    person_mapper.belongs_to :parent, person_model
  end

  it 'loads the associated parent' do
    jane = ROM_ENV[person_model].include(:parent).one(:id => 2)

    john = jane.parent

    john.id.should == 1
    john.name.should == 'John'
  end
end
