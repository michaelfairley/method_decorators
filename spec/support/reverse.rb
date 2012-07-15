class Reverse < MethodDecorator
  def call(orig, this, *args, &blk)
    orig.call(*args.reverse, &blk)
  end
end