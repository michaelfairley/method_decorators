require "method_decorators"

module MethodDecorators
  class Precondition < Decorator
    def initialize(&blk)
      @block = blk
    end

    def call(orig, this, *args, &blk)
      unless passes?(this, *args)
        raise ArgumentError, "failed precondition"
      end
      orig.call(*args, &blk)
    end

  private

    def passes?(context, *args)
      context.instance_exec(*args, &@block)
    end
  end
end
