module MethodDecorators
  class Retry < Decorator
    def initialize(max)
      @max = max
    end

    def call(orig, this, *args, &blk)
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
end
