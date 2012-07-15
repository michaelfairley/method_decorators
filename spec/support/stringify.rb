class Stringify < MethodDecorator
  def call(orig, this, *args, &blk)
    orig.call(*args, &blk).to_s
  end
end
