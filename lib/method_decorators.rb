require "method_decorators/version"
require "method_decorators/decorator"

module MethodDecorators
  def method_added(name)
    super
    orig_method = instance_method(name)

    decorators = Decorator.current_decorators
    return  if decorators.empty?

    if    private_method_defined?(name);   visibility = :private
    elsif protected_method_defined?(name); visibility = :protected
    else                                   visibility = :public
    end

    define_method(name) do |*args, &blk|
      decorated = MethodDecorators.decorate_callable(orig_method.bind(self), decorators)
      decorated.call(*args, &blk)
    end

    case visibility
    when :protected; protected name
    when :private;   private name
    end
  end

  def singleton_method_added(name)
    super
    orig_method = method(name)

    decorators = Decorator.current_decorators
    return  if decorators.empty?

    MethodDecorators.define_others_singleton_method(self, name) do |*args, &blk|
      decorated = MethodDecorators.decorate_callable(orig_method, decorators)
      decorated.call(*args, &blk)
    end
  end

  def self.decorate_callable(orig, decorators)
    decorators.reduce(orig) do |callable, decorator|
      lambda{ |*a, &b| decorator.call(callable, orig.receiver, *a, &b) }
    end
  end

  def self.define_others_singleton_method(klass, name, &blk)
    if klass.respond_to?(:define_singleton_method)
      klass.define_singleton_method(name, &blk)
    else
      class << klass
        self
      end.send(:define_method, name, &blk)
    end
  end
end
