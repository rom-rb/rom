# encoding: utf-8

shared_context 'Environment' do
  let(:object) { Environment.setup(test: 'memory://test').finalize }
  let(:uri)    { 'memory://test' }
end
