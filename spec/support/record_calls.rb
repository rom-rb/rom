class RecordCalls
  def initialize
    @calls = []
  end

  def record_call(*args)
    calls << args
  end

  def call_count
    calls.length
  end

  def to_proc
    public_method(:record_call).to_proc
  end

  attr_reader :calls
end

