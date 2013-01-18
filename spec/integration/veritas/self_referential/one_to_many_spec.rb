require 'spec_helper_integration'

describe 'Relationship - Self referential One To Many' do
  include_context 'Models and Mappers'

  before(:all) do
    setup_db

    insert_person 1, 'John'
    insert_person 2, 'Jane',  1
    insert_person 3, 'Alice', 1

    person_mapper.has 0..n, :children, person_model, :target_key => [:parent_id]

    # FIXME investigate why #one returns zero results when
    # this is defined *before* the :children relationship
    person_mapper.belongs_to :parent, person_model
  end

  let(:jane)  { person_model.new(:id => 2, :name => 'Jane',  :parent_id => 1) }
  let(:alice) { person_model.new(:id => 3, :name => 'Alice', :parent_id => 1) }

  it 'loads the associated children' do
    children = DM_ENV[person_model].include(:children).one(:id => 1).children

    children.size.should == 2

    children.should include(jane)
    children.should include(alice)
  end
end
