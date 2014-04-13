require "method_decorators"

module MethodDecorators
  class Retry < Decorator
    def initialize(max, options = {})
      @max = max
      @options = options
    end

    def call(orig, this, *args, &blk)
      attempts = 0
      begin
        attempts += 1
        orig.call(*args, &blk)
      rescue
        if attempts < @max
          sleep(@options[:sleep]) if @options[:sleep]
          retry
        end
        raise
      end
    end
  end
end
