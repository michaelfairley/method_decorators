class Memoize < MethodDecorator
  def initialize
    @cache ||= {}
    super
  end

  def call(orig, *args, &blk)
    return @cache[args] if @cache.has_key?(args)
    @cache[args] = orig.call(*args, &blk)
  end
end
