require 'spec_helper'

describe Relation::Mapper, '.repository' do
  let(:name) { DM_REPO_NAME }

  context "with a name" do
    it "sets the repository name" do
      described_class.repository(name)
      described_class.repository.should be(name)
    end
  end
end
