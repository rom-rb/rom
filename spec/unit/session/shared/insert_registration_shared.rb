shared_examples_for 'an insert registration' do
  it 'should register insert' do
    subject
    object.insert?(domain_object).should be_true
  end

  it 'should NOT track domain object' do
    subject
    object.track?(domain_object).should be_false
  end
end
