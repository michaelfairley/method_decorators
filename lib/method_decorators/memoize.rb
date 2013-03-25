require "method_decorators"

module MethodDecorators
  class Memoize < Decorator
    def call(orig, this, *args, &blk)
      return cache(this)[args] if cache(this).has_key?(args)
      cache(this)[args] = orig.call(*args, &blk)
    end

    private
    def cache(this)
      this.instance_eval do
        return @_memoize_cache ||= {}
      end
    end
  end
end
