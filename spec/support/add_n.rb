class AddN < MethodDecorators::Decorator
  def initialize(n)
    @n = n
  end

  def call(orig, this, *args, &blk)
    orig.call(*args, &blk) + @n
  end
end
