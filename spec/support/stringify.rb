class Stringify < MethodDecorator
  def call(orig, *args, &blk)
    orig.call(*args, &blk).to_s
  end
end
