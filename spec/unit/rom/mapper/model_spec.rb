require 'spec_helper'

describe Mapper, '#model' do
  subject { mapper.model }

  include_context 'Mapper'

  it { should be(model) }
end
