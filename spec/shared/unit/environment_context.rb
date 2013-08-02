# encoding: utf-8

shared_context 'Environment' do
  let(:object) { Environment.coerce(test: 'memory://test') }
  let(:uri)    { 'memory://test' }
end
