# frozen_string_literal: true

require 'spec_helper'
require 'rom/lint/spec'
require 'rom/memory'

RSpec.describe ROM::Memory::Gateway do
  let(:gateway) { ROM::Memory::Gateway }
  let(:uri) { nil }

  it_behaves_like 'a rom gateway' do
    let(:identifier) { :memory }
  end
end
