# encoding: utf-8

require 'spec_helper'

describe Environment, '#repository' do
  include_context 'Environment'

  subject { object.repository(name) }

  context 'when repository exists' do
    let(:name) { :test }

    it { should be_instance_of(Repository) }
  end

  context 'when is not known' do
    let(:name) { :not_here }

    it { should be(nil) }
  end
end
