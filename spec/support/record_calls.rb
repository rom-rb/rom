class RecordCalls
  def initialize(&blk)
    @blk = blk
    @calls = []
  end

  def call_count
    calls.length
  end

  def call(*args)
    record_call(*args)
    blk.call(*args)
  end

  def to_proc
    public_method(:call).to_proc
  end

  attr_reader :calls

  private

  attr_reader :blk

  def record_call(*args)
    calls << args
  end
end

