require "method_decorators"

module MethodDecorators
  class Memoize < Decorator
    def initialize
      @memo_ivar = "@_memoize_cache#{rand(10**10)}"
    end

    def call(orig, this, *args, &blk)
      return cache(this)[args] if cache(this).has_key?(args)
      cache(this)[args] = orig.call(*args, &blk)
    end

    private
    def cache(this)
      memo_ivar = @memo_ivar
      this.instance_eval do
        instance_variable_get(memo_ivar) || instance_variable_set(memo_ivar, {})
      end
    end
  end
end
