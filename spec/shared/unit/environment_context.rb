# encoding: utf-8

shared_context 'Environment' do
  let(:object) { Environment.setup(test: 'memory://test') }
  let(:uri)    { 'memory://test' }
end
