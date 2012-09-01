require 'dm-mapper'

begin
  require 'rspec'  # try for RSpec 2
rescue LoadError
  require 'spec'   # try for RSpec 1
  RSpec = Spec::Runner
end

RSpec.configure do |config|
  config.before(:all, :type => :unit) do
    @_mocked_models = []
  end

  config.after(:each, :type => :unit) do
    clear_mocked_models
  end

  def mock_model(type)
    @_mocked_models << type
    Object.const_set(type, Class.new(OpenStruct))
  end

  def mock_mapper(model_class)
    Class.new(DataMapper::Mapper) do
      model model_class

      def inspect
        "#<#{self.class.model}Mapper:#{object_id} model=#{self.class.model}>"
      end
    end
  end

  def clear_mocked_models
    @_mocked_models.each { |name| Object.send(:remove_const, name) }
  end
end
