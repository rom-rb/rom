require 'spec_helper'

describe Mapper, '.build' do
  subject { described_class.build(header, model) }

  let(:model) { OpenStruct }

  fake(:header) { Mapper::Header }

  its(:loader) { should be_instance_of(Mapper::DEFAULT_LOADER) }
  its(:dumper) { should be_instance_of(Mapper::DEFAULT_DUMPER) }
end
