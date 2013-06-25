require 'spec_helper'

describe Session::Relation, '#save' do
  subject { object.identity(user) }

  include_context 'Session::Relation'

  it { should eq([ user.id ]) }
end
