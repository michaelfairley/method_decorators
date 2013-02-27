module MethodDecorators
  class Memoize < Decorator
    def call(orig, this, *args, &blk)
      return cache(this)[args] if cache(this).has_key?(args)
      cache(this)[args] = orig.call(*args, &blk)
    end

    private
    def cache(this)
      this.instance_variable_get("@_memoize_cache") || this.instance_variable_set("@_memoize_cache", {})
    end
  end
end
