# frozen_string_literal: true

require 'rom/repository'

RSpec.describe ROM::Repository, '.[]' do
  subject(:repo) do
    Class.new(ROM::Repository)
  end

  let(:relation) { :users }

  it 'creates a preconfigured ROM::Repository:Root class' do
    expect(repo[relation].root).to be(relation)
  end

  it 'caches the class' do
    expect(repo[relation]).to be(repo[relation])
  end
end
