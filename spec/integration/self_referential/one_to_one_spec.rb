require 'spec_helper_integration'

describe 'Relationship - Self referential One To One' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_person 1, 'John'
    insert_person 2, 'Jane',  1

    person_mapper.has 1, :child, person_model, :target_key => [:parent_id]

    # FIXME investigate why #one returns zero results when
    # this is defined *before* the :children relationship
    person_mapper.belongs_to :parent, person_model
  end

  it 'loads the associated children' do
    pending if RUBY_VERSION < '1.9'

    jane = DM_ENV[person_model].include(:child).one(:id => 1).child

    jane.id.should == 2
    jane.name.should == 'Jane'
  end
end
