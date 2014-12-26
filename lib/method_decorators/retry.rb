require "method_decorators"

module MethodDecorators
  class Retry < Decorator
    def initialize(max, options = {})
      @max = max
      @options = options
      @exceptions = options[:exceptions] || [StandardError]
    end

    def call(orig, this, *args, &blk)
      attempts = 0
      begin
        attempts += 1
        orig.call(*args, &blk)
      rescue *@exceptions
        if attempts < @max
          sleep(@options[:sleep]) if @options[:sleep]
          retry
        end
        raise
      end
    end
  end
end
