class AddN < MethodDecorator
  def initialize(n)
    @n = n
  end

  def call(orig, *args, &blk)
    orig.call(*args, &blk) + @n
  end
end