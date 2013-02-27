require 'timeout'

module MethodDecorators
  class Within < Decorator
    def initialize(timeout)
      @seconds = timeout
    end

    def call(orig, this, *args, &blk)
      Timeout::timeout(@seconds) do
        orig.call(*args, &blk)
      end
    end
  end
end
