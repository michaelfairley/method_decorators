class Reverse < MethodDecorator
  def call(orig, *args, &blk)
    orig.call(*args.reverse, &blk)
  end
end