require 'spec_helper'

describe Session::Relation, '#delete' do
  subject { users.delete(user).state(user) }

  include_context 'Session::Relation'

  it { should be_deleted }
end
