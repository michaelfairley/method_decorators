require "method_decorators/version"

module MethodDecorators
  def method_added(name)
    super
    orig_method = instance_method(name)

    if    private_method_defined?(name);   visibility = :private
    elsif protected_method_defined?(name); visibility = :protected
    else                                   visibility = :public
    end

    decorators = MethodDecorator.current_decorators
    return  if decorators.empty?

    define_method(name) do |*args, &blk|
      decorators.reduce(orig_method.bind(self)) do |callable, decorator|
        lambda{|*a, &b| decorator.call(callable, *a, &b) }
      end.call(*args, &blk)
    end

    case visibility
    when :protected; protected name
    when :private;   private name
    end
  end

  def singleton_method_added(name)
    super
    orig_method = method(name)

    decorators = MethodDecorator.current_decorators
    return  if decorators.empty?

    define_singleton_method(name) do |*args, &blk|
      decorators.reduce(orig_method) do |callable, decorator|
        lambda{|*a, &b| decorator.call(callable, *a, &b) }
      end.call(*args, &blk)
    end
  end
end

class MethodDecorator
  @@current_decorators = []

  def self.current_decorators
    decs = @@current_decorators
    @@current_decorators = []
    decs
  end

  def self.+@
    +new
  end

  def +@
    @@current_decorators.unshift(self)
  end
end