shared_examples_for 'an operation that dumps once' do
  it 'should dump only once' do
    dumper = mapper.dumper(domain_object)
    mapper.should_receive(:dumper).once.and_return(dumper)
    subject
  end
end
