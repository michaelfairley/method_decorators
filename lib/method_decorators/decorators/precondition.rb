class Precondition < MethodDecorator
  def initialize(&blk)
    @block = blk
  end

  def call(orig, *args, &blk)
    unless passes?(orig.receiver, *args)
      raise ArgumentError, "failed precondition"
    end
    orig.call(*args, &blk)
  end

private

  def passes?(context, *args)
    context.instance_exec(*args, &@block)
  end
end
