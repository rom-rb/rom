shared_examples_for 'an update registration' do
  it 'should mark domain object as to be updated' do
    subject
    object.update?(domain_object).should be_true
  end

  it 'should track domain object' do
    object.track?(domain_object).should be_true
  end
end
