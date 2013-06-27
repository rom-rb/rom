shared_context 'Environment' do
  let(:object) { described_class.coerce(:test => 'in_memory://test') }
  let(:uri)    { 'in_memory://test' }
end
