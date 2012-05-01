class Retry < MethodDecorator
  def initialize(max)
    @max = max
  end

  def call(orig, *args, &blk)
    attempts = 0
    begin
      attempts += 1
      orig.call(*args, &blk)
    rescue
      retry  if attempts < @max
      raise
    end
  end
end
