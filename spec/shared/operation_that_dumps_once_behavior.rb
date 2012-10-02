shared_examples_for 'an operation that dumps once' do
  it 'should dump only once' do
    dump = mapper.dump(domain_object)
    key  = mapper.dump_key(domain_object)
    mapper.should_receive(:dump).once.and_return(dump)
    mapper.should_receive(:dump_key).at_most(:once).and_return(key)
    subject
  end
end
