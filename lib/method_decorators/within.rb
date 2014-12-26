require "method_decorators"
require 'timeout'

module MethodDecorators
  class Within < Decorator
    def initialize(timeout, exception_class = nil)
      @seconds = timeout
      @exception_class = exception_class
    end

    def call(orig, this, *args, &blk)
      Timeout.timeout(@seconds, @exception_class) do
        orig.call(*args, &blk)
      end
    end
  end
end
