class Memoize < MethodDecorator
  attr_accessor :memo

  def initialize(*)
    self.memo ||= {}
    super
  end

  def call(orig, *args, &blk)
    return memo[args] if memo.has_key?(args)
    memo[args] = orig.call(*args, &blk)
  end
end
