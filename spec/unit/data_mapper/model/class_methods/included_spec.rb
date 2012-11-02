require 'spec_helper'

describe Model, '.included' do
  subject { Class.new { include Model } }

  it { should be < Virtus }
end
