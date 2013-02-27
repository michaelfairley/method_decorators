class Reverse < MethodDecorators::Decorator
  def call(orig, this, *args, &blk)
    orig.call(*args.reverse, &blk)
  end
end
