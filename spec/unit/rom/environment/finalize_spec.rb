require 'spec_helper'

describe Environment, '#finalize' do
  include_context 'Environment'

  subject { object.finalize }

  it { should be(object) }
end
