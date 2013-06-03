require 'spec_helper'

describe ROM::Mapper, '.model' do
  let(:model_class) { mock_model(:TestModel) }

  context "with a model class" do
    it "sets the model" do
      described_class.model(model_class)
      described_class.model.should be(model_class)
    end
  end
end
